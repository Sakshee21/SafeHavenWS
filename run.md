# Run Guide

This guide shows how to run everything locally (contracts, backend, web portal, Flutter) and how to deploy contracts.

## Prerequisites
- Node.js 18+
- npm
- Git
- Flutter SDK (to run the mobile app)

Optional:
- Android SDK / Xcode if you target mobile devices
- Firebase project if you want Firestore features and push notifications

## 1) Smart Contracts (Hardhat)

**Check if Hardhat node is already running:**
```bash
curl -s http://127.0.0.1:8545 -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result'
```
If you get a block number (e.g., `0xd`), the node is running and you can skip to Terminal B.

**If port 8545 is in use but node isn't responding, kill it:**
```bash
lsof -ti:8545 | xargs kill -9
# Or find the process:
ps aux | grep 'hardhat node' | grep -v grep
# Then kill it manually with: kill <PID>
```

Terminal A (if node not running):
```bash
cd smartcontracts
npm install
# Start local chain
npx hardhat node --hostname 127.0.0.1
```

Terminal B (deploy to the local node and export ABIs/addresses to backend):
```bash
cd smartcontracts
npx hardhat run scripts/deploy.js --network localhost
```
This writes `backend/deployedAddresses.json` and ABI files to `backend/abis/`.

### Deploying to Sepolia (optional)
1. Set env vars (example):
```bash
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/<YOUR_KEY>"
export PRIVATE_KEY="0x...your deployer private key..."
```
2. Update `hardhat.config.js` with a `sepolia` network (RPC + accounts), then:
```bash
npx hardhat run scripts/deploy.js --network sepolia
```
3. Copy the produced addresses to `backend/deployedAddresses.json` on the server and ensure `RPC_URL` points to Sepolia.

## 2) Backend (Node/Express)

Terminal C:
```bash
cd backend
npm install
# (optional) create .env
cat > .env << 'EOF'
PORT=5000
RPC_URL=http://127.0.0.1:8545
# Hardhat default account #0 for local dev
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
EOF

npm start
```

- Root: `GET http://localhost:5000/`
- Stats: `GET http://localhost:5000/api/stats`
- NGO cases: `GET http://localhost:5000/api/ngo/cases`
- Nearby: `GET http://localhost:5000/api/cases/nearby?lat=12.34&lng=56.78&radiusKm=10`

The backend includes an escalation worker that runs every minute to auto-escalate stale cases (>60 min).

Firestore routes are disabled unless `backend/serviceAccountKey.json` exists.

## 3) Web Portal (Next.js + TypeScript)

Terminal D:
```bash
cd portal
npm install
npm run dev   # http://localhost:3000
```
- Landing: `http://localhost:3000/`
- NGO Dashboard: `http://localhost:3000/ngo`

Production build check:
```bash
npm run build && npm start
```

If backend runs on a different host, set `NEXT_PUBLIC_API_BASE` before starting:
```bash
export NEXT_PUBLIC_API_BASE="http://your-backend-host:5000"
npm run dev
```

## 4) Flutter App (Optional)
```bash
cd safehaven
flutter pub get
flutter run
```
- User Home: Send SOS → calls backend `/api/cases/create` with GPS location
- Volunteer Home: Nearby cases → accept and submit report

Make sure your device/emulator can reach `http://localhost:5000`. Use your machine IP if needed.

## Quick Start Script (Optional)

A helper script is provided to start backend + portal automatically:
```bash
./start-all.sh
```
This script:
- Checks if Hardhat node is running
- Deploys contracts if needed
- Starts backend and portal
- Shows all service URLs

**Note:** Make sure Hardhat node is running first (Terminal A).

## Common Pitfalls
- Start Hardhat node first, then deploy, then start backend.
- If routes 404, ensure `backend/deployedAddresses.json` exists (from the deploy script).
- If Flutter cannot connect to backend, replace `localhost` with your machine IP in `ApiService.baseUrl`.
- For Sepolia, ensure `RPC_URL` and `PRIVATE_KEY` are set in backend `.env` and contracts deployed addresses are updated.
- If backend fails to start, check that Hardhat node is accessible at `http://127.0.0.1:8545`.

## What gets deployed
- Contracts: via `smartcontracts/scripts/deploy.js`, which also exports addresses and ABIs to the backend.
- Backend: Node service; no build step required (just `npm start`).
- Portal: Next.js; `npm run build && npm start` for production.
- Flutter: Build using `flutter build apk` or `flutter build ios` as required.
