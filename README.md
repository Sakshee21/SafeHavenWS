# SafeHavenWS-Blockchain

A full-stack prototype for SafeHaven: a web3-assisted safety platform where users can raise SOS cases recorded on-chain, volunteers can assist and submit reports, and roles are managed transparently via smart contracts. The repo contains:

- `smartcontracts/`: Solidity contracts + Hardhat tooling
- `backend/`: Node/Express API that talks to the blockchain and Firestore
- `safehaven/`: Flutter mobile app (Firebase auth + SOS & volunteer screens)
- `portal/`: Next.js + TypeScript web portal (landing page + NGO dashboard)

## Architecture Overview

### Smart Contracts
- **RoleManagerContract**: Role registry with string roles ("User", "Volunteer", "NGO").
- **CaseContract**: Creates SOS cases with lifecycle states (Pending → Acknowledged → Escalated/Resolved/FalseAlarm). Stores GPS coordinates, timestamps, assigned volunteers, and acknowledged-by-NGO addresses. Includes `markFalseAlarm()` function for users to mark their own cases.
- **CaseRegistry**: Index of case IDs per victim. Allows querying all cases by user address.
- **VolunteerReportContract**: Handles volunteer acceptances and reports.

### Backend API (`/api/*`)
- **Contracts**: Test connectivity, assign/check roles
- **Cases**: Create, read, and query nearby cases (by radius)
- **NGO**: List active cases, acknowledge, escalate, resolve, assign volunteers
- **Volunteers**: Accept cases, submit reports
- **Stats**: Public statistics (total, open, acknowledged, escalated, resolved)

### Frontend
- **Portal** (Next.js): Landing page with live stats + NGO dashboard with real-time case feed, timers (30/60-min thresholds), and action buttons
- **Flutter App**: User SOS creation (with GPS), Volunteer nearby cases, accept, and report submission

### Automation
- **Escalation Worker**: Runs every minute; auto-escalates cases pending/acknowledged > 60 minutes

## Prerequisites

- Node.js 18+
- npm
- (Recommended) Java/JDK + Android SDK + Flutter if you plan to run the mobile app

## Quick Start (Local Development)

### 1) Start local blockchain and deploy contracts

```bash
# In a terminal
cd smartcontracts
npm install
npx hardhat node --hostname 127.0.0.1    # keep running
```

Open a new terminal to deploy (this also exports ABIs + addresses for the backend):

```bash
cd smartcontracts
npx hardhat run scripts/deploy.js --network localhost
```

This writes `backend/deployedAddresses.json` and copies ABIs into `backend/abis/`.

### 2) Run the backend API

```bash
cd backend
npm install
npm start
```

**Main endpoints:**
- Root: GET `http://localhost:5000/` → "SafeHaven Backend is running!"
- Stats: GET `http://localhost:5000/api/stats` → `{ total, open, acknowledged, escalated, resolved }`
- NGO cases: GET `http://localhost:5000/api/ngo/cases` → Active cases list
- NGO actions: POST `/api/ngo/acknowledge/:id`, `/api/ngo/resolve/:id`, `/api/ngo/escalate/:id`, `/api/ngo/assign/:id` (body: `{ volunteer: "0x..." }`)
- Nearby cases: GET `/api/cases/nearby?lat=12.34&lng=56.78&radiusKm=10`
- Volunteer: POST `/api/volunteers/accept/:id`, POST `/api/volunteers/report/:id` (body: `{ text: "..." }`)
- Create case: POST `/api/cases/create` with JSON `{ "latitude": "12.34", "longitude": "56.78" }`
- Get case: GET `/api/cases/:id`
- Get user cases: GET `/api/cases/user/:address` → Returns all cases created by a specific user address
- Mark false alarm: POST `/api/cases/markFalseAlarm/:id` → Marks a case as false alarm (only by case creator)

Note: Firestore-backed routes are auto-disabled unless `backend/serviceAccountKey.json` is present.

### 3) Run the web portal (Next.js)

```bash
cd portal
npm install
npm run dev    # Runs on http://localhost:3000
```

- Landing page: `http://localhost:3000/` (shows live stats)
- NGO dashboard: `http://localhost:3000/ngo` (real-time case feed with timers)

### 4) (Optional) Run Flutter app

```bash
cd safehaven
flutter pub get
flutter run   # or: flutter build apk / flutter build web
```

**Note:** Add `http` and `geolocator` dependencies (already in `pubspec.yaml`). The app uses:
- **User home**: SOS button that creates a case with current GPS location
- **My Cases page**: View all cases created by the user, with ability to mark cases as false alarm
- **Volunteer home**: Lists nearby cases, accept action, and report submission dialog

Firebase is initialized via `lib/firebase_options.dart`. Ensure your `google-services.json`/`GoogleService-Info.plist` are correct.

## Environment Variables

Backend `.env` (optional):

```bash
# HTTP port
PORT=5000

# EVM RPC (defaults to Hardhat localhost)
RPC_URL=http://127.0.0.1:8545

# Private key used for write operations from the backend (defaults to Hardhat acct #0)
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Optional explicit contract addresses (otherwise taken from deployedAddresses.json)
ROLE_MANAGER_ADDRESS=
CASE_CONTRACT_ADDRESS=
CASE_REGISTRY_ADDRESS=
VOLUNTEER_REPORT_ADDRESS=
```

If you want Firestore integration enabled, place your Firebase Admin credential at `backend/serviceAccountKey.json` (never commit this file).

## Troubleshooting

- Ensure the Hardhat node is running at `http://127.0.0.1:8545` before starting the backend.
- If the backend cannot find contracts, re-run the deployment step to regenerate `backend/deployedAddresses.json`.
- If role-restricted calls revert (e.g., creating a case), assign the role first:

```bash
# Assign 'User' role to an address via Hardhat script
cd smartcontracts
npx hardhat run scripts/grantUser.js --network localhost
```

- The Firestore routes are skipped unless `backend/serviceAccountKey.json` exists. This is by design for local development without Firebase.

## Features Implemented

✅ **Smart Contracts**
- Case lifecycle (Pending → Acknowledged → Escalated/Resolved)
- NGO role and permissions
- Volunteer assignment and reporting
- All tests passing

✅ **Backend**
- REST API with NGO, volunteer, and case management endpoints
- Automatic escalation worker (60-minute threshold)
- Stats endpoint for public dashboard

✅ **Web Portal (Next.js + TypeScript)**
- **Full pitch website** with:
  - Hero section with live statistics
  - About section (problem & solution)
  - Workflow section (step-by-step process)
  - Tech stack showcase
  - Team section
  - Development journey timeline
  - Live demo & results section
  - Footer with links
- **NGO dashboard** (`/ngo`) with:
  - Real-time case feed (auto-refreshes every 5s)
  - Case age timers with visual warnings (30min/60min thresholds)
  - Action buttons: Acknowledge, Escalate, Resolve
  - Volunteer assignment interface

✅ **Flutter Mobile App**
- User SOS creation with GPS location
- **My Cases page**: View user's own cases with status, timestamps, and location
- **Mark False Alarm**: Users can mark their own cases as false alarms
- Volunteer nearby cases view
- Accept and report submission flows
- Backend API integration

## Project Status

- ✅ Contracts compile and all tests pass under Hardhat
- ✅ Backend API fully functional with escalation automation
- ✅ Web portal operational (landing + NGO dashboard)
- ✅ Flutter app integrated with backend APIs
- 🔲 Firestore caching (optional, for faster UI; backend can work without it)

## Protocol: 30-Minute Escalation System

The system automatically escalates cases that remain unacknowledged or unresolved:

1. **0-30 minutes**: Pending (highlighted in yellow)
2. **30-60 minutes**: Urgent (highlighted in orange)
3. **>60 minutes**: Auto-escalated to "Escalated" status (highlighted in red)

The backend worker runs every minute and checks all cases, auto-escalating those exceeding 60 minutes.

## New Features (MVP Completion)

### ✅ Smart Contract Enhancements
- Added `FalseAlarm` status to `CaseStatus` enum
- Implemented `markFalseAlarm(uint _caseId)` function - only the case creator can mark their case as false alarm
- Added `CaseUpdated` event for tracking false alarm markings

### ✅ Backend API Enhancements
- **GET `/api/cases/user/:address`**: Retrieve all cases created by a specific user address
- **POST `/api/cases/markFalseAlarm/:id`**: Mark a case as false alarm (only by creator)

### ✅ Flutter App Enhancements
- **My Cases Screen**: New page showing all cases created by the user
  - Displays case ID, status, GPS coordinates, timestamp
  - Color-coded status indicators (Pending, Acknowledged, Escalated, Resolved, False Alarm)
  - "Mark as False Alarm" button for active cases
  - Pull-to-refresh functionality
- Updated bottom navigation to include "My Cases" for users

### ✅ Presentation Website
- Complete redesign of landing page (`/`) with all required sections:
  - Hero section with gradient background and live stats
  - About section explaining problem and solution
  - Workflow section with 7-step process visualization
  - Tech stack showcase with icons
  - Team section
  - Development journey timeline
  - Live demo & results section
  - Professional footer

## Testing & Demo

See `test_data.md` for:
- Test accounts and private keys
- Test scenarios and expected outcomes
- API testing with cURL commands
- Role assignment commands
- Demo flow checklist

## Project Structure

```
SafeHavenWS-Blockchain/
├── smartcontracts/          # Solidity contracts + Hardhat
│   ├── contracts/
│   │   ├── CaseContract.sol          # Case management with FalseAlarm
│   │   ├── CaseRegistry.sol          # Case indexing by user
│   │   ├── RoleManagerContract.sol   # Role management
│   │   └── VolunteerReportContract.sol
│   ├── scripts/
│   │   ├── deploy.js
│   │   └── grantUser.js
│   └── test/
├── backend/                  # Node.js + Express API
│   ├── routes/
│   │   ├── caseRoutes.js     # Case CRUD + markFalseAlarm + getUserCases
│   │   ├── volunteer.js
│   │   ├── ngo.js
│   │   └── stats.js
│   └── server.js
├── safehaven/               # Flutter mobile app
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   ├── user_home.dart
│   │   │   │   └── volunteer_home.dart
│   │   │   └── cases/
│   │   │       └── my_cases_screen.dart  # NEW
│   │   └── services/
│   │       └── api_service.dart         # Updated with new endpoints
│   └── pubspec.yaml
├── portal/                  # Next.js presentation website
│   └── app/
│       ├── page.tsx         # Full pitch website (UPDATED)
│       └── ngo/
│           └── page.tsx     # NGO dashboard
└── test_data.md             # Test accounts and demo guide
```

## Deployment Options

### Offline Mode (Local Hardhat)
- Start Hardhat node: `npx hardhat node --hostname 127.0.0.1`
- Deploy contracts: `npx hardhat run scripts/deploy.js --network localhost`
- Backend uses local RPC: `http://127.0.0.1:8545`

### Online Mode (Polygon Mumbai Testnet)
1. Update `hardhat.config.js` with Mumbai RPC and deployer account
2. Deploy: `npx hardhat run scripts/deploy.js --network mumbai`
3. Update `backend/deployedAddresses.json` with deployed addresses
4. Set `RPC_URL` in backend `.env` to Mumbai RPC endpoint
5. Fund deployer account with Mumbai MATIC (from faucet)

## Security & Privacy

- **User Identity**: Stored off-chain (Firebase Auth)
- **On-Chain Data**: Only GPS coordinates, timestamps, and case metadata
- **No Data Deletion**: Cases can only be marked as "False Alarm" or "Resolved", never deleted
- **Role-Based Access**: Enforced by smart contracts
- **Immutable Records**: All case data permanently stored on blockchain

Contributions and issues are welcome.