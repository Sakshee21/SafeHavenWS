#!/bin/bash
# Quick start script for SafeHaven - starts all services
# Usage: ./start-all.sh

set -e

echo "🚀 SafeHaven Quick Start"
echo "========================"

# Check if Hardhat node is running
if curl -s http://127.0.0.1:8545 -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null 2>&1; then
  echo "✅ Hardhat node already running on port 8545"
else
  echo "⚠️  Hardhat node not running. Please start it in a separate terminal:"
  echo "   cd smartcontracts && npx hardhat node --hostname 127.0.0.1"
  exit 1
fi

# Check if contracts are deployed
if [ ! -f "backend/deployedAddresses.json" ]; then
  echo "⚠️  Contracts not deployed. Deploying now..."
  cd smartcontracts
  npx hardhat run scripts/deploy.js --network localhost
  cd ..
fi

# Start backend
echo "📦 Starting backend..."
cd backend
if [ ! -d "node_modules" ]; then
  npm install
fi
npm start &
BACKEND_PID=$!
echo "   Backend PID: $BACKEND_PID"
cd ..
sleep 2

# Check backend health
if curl -s http://localhost:5000/ > /dev/null; then
  echo "✅ Backend running on http://localhost:5000"
else
  echo "❌ Backend failed to start"
  kill $BACKEND_PID 2>/dev/null || true
  exit 1
fi

# Start portal
echo "🌐 Starting portal..."
cd portal
if [ ! -d "node_modules" ]; then
  npm install
fi
npm run dev &
PORTAL_PID=$!
echo "   Portal PID: $PORTAL_PID"
cd ..
sleep 3

echo ""
echo "✅ All services started!"
echo ""
echo "📍 Backend:  http://localhost:5000"
echo "📍 Portal:   http://localhost:3000"
echo "📍 NGO:      http://localhost:3000/ngo"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for Ctrl+C
trap "echo ''; echo '🛑 Stopping services...'; kill $BACKEND_PID $PORTAL_PID 2>/dev/null || true; exit" INT
wait

