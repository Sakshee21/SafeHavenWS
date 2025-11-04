# SafeHavenWS - Test Data & Demo Guide

## 🧪 Test Accounts & Demo Setup

### Hardhat Local Network Accounts

When running `npx hardhat node`, you'll get 20 pre-funded accounts. Here are the first few for testing:

```
Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (Backend signer)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (User 1 - Victim)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

Account #2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (User 2 - Victim)
Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

Account #3: 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (User 3 - Victim)
Private Key: 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

Account #4: 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (Volunteer 1)
Private Key: 0x47e179ec197488593b187f80a00eb1da5159cb640c62bfe557b99b9462e46b32

Account #5: 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc (Volunteer 2)
Private Key: 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba

Account #6: 0x976EA74026E726554dB657fA54763abd0C3a0aa9 (NGO)
Private Key: 0x92db14e403b53cdb6633275ba9c3cb76601d37247bf5f27248244ee847265af5
```

## 📝 Test Scenarios

### Scenario 1: User Creates SOS Case

1. **Setup**: Start Hardhat node, deploy contracts, start backend
2. **Action**: User sends SOS from Flutter app
3. **Expected**: 
   - Case created on blockchain with GPS coordinates
   - Case ID returned
   - Case visible in "My Cases" page
   - Case appears in NGO dashboard

### Scenario 2: Volunteer Views and Accepts Case

1. **Setup**: At least one case exists
2. **Action**: Volunteer opens app, views nearby cases, accepts one
3. **Expected**:
   - Nearby cases list shows cases within radius
   - Accept button assigns volunteer to case
   - Transaction hash returned

### Scenario 3: Volunteer Submits Report

1. **Setup**: Volunteer has accepted a case
2. **Action**: Volunteer submits report with details
3. **Expected**:
   - Report logged on VolunteerReportContract
   - Case status updated
   - Report visible in blockchain logs

### Scenario 4: User Marks False Alarm

1. **Setup**: User has created a case
2. **Action**: User opens "My Cases", marks case as false alarm
3. **Expected**:
   - Case status changes to "FalseAlarm"
   - Case no longer appears in active cases
   - Transaction confirmed on blockchain

### Scenario 5: NGO Acknowledges and Escalates

1. **Setup**: Case exists in Pending status
2. **Action**: NGO acknowledges case, then escalates if needed
3. **Expected**:
   - Case status: Pending → Acknowledged → Escalated
   - Automatic escalation after 60 minutes if not resolved

## 🔧 Role Assignment Commands

Assign roles using Hardhat console or scripts:

```bash
cd smartcontracts
npx hardhat console --network localhost
```

Then in console:
```javascript
const RoleManager = await ethers.getContractAt("RoleManagerContract", "0x...ROLE_MANAGER_ADDRESS");
const signer = await ethers.getSigner(0); // Account #0

// Assign User role to Account #1
await RoleManager.assignRole("0x70997970C51812dc3A010C7d01b50e0d17dc79C8", "User");

// Assign Volunteer role to Account #4
await RoleManager.assignRole("0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65", "Volunteer");

// Assign NGO role to Account #6
await RoleManager.assignRole("0x976EA74026E726554dB657fA54763abd0C3a0aa9", "NGO");
```

Or use the provided script:
```bash
npx hardhat run scripts/grantUser.js --network localhost
```

## 📊 Sample Test Data

### Test Cases (GPS Coordinates)

1. **Case 1**: Latitude: 12.9716, Longitude: 77.5946 (Bangalore, India)
2. **Case 2**: Latitude: 19.0760, Longitude: 72.8777 (Mumbai, India)
3. **Case 3**: Latitude: 28.6139, Longitude: 77.2090 (Delhi, India)

### Expected Blockchain Events

After creating a case, you should see:
- `CaseCreated` event with caseId, victim address, latitude, longitude
- `CaseIndexed` event in CaseRegistry

After volunteer actions:
- `CaseAccepted` event from VolunteerReportContract
- `ReportSubmitted` event

After NGO actions:
- `CaseAcknowledged` event
- `VolunteerAssigned` event
- `CaseEscalated` event
- `CaseResolved` event

## 🧪 API Testing with cURL

### Create Case
```bash
curl -X POST http://localhost:5000/api/cases/create \
  -H "Content-Type: application/json" \
  -d '{"latitude": "12.9716", "longitude": "77.5946"}'
```

### Get Case by ID
```bash
curl http://localhost:5000/api/cases/1
```

### Get User Cases
```bash
curl http://localhost:5000/api/cases/user/0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
```

### Mark False Alarm
```bash
curl -X POST http://localhost:5000/api/cases/markFalseAlarm/1
```

### Get Nearby Cases
```bash
curl "http://localhost:5000/api/cases/nearby?lat=12.9716&lng=77.5946&radiusKm=10"
```

### Volunteer Accept Case
```bash
curl -X POST http://localhost:5000/api/volunteers/accept/1
```

### Volunteer Submit Report
```bash
curl -X POST http://localhost:5000/api/volunteers/report/1 \
  -H "Content-Type: application/json" \
  -d '{"text": "Case verified, victim safe"}'
```

### Get Stats
```bash
curl http://localhost:5000/api/stats
```

## 🎯 Demo Flow Checklist

- [ ] Start Hardhat node
- [ ] Deploy contracts
- [ ] Start backend server
- [ ] Start portal (Next.js)
- [ ] Assign roles to test accounts
- [ ] Create 3 test cases (as 3 different users)
- [ ] Mark 1 case as false alarm
- [ ] Have 2 volunteers accept cases
- [ ] Have volunteers submit reports
- [ ] Check NGO dashboard shows all cases
- [ ] Verify blockchain events in Hardhat console
- [ ] Test automatic escalation (wait 60+ minutes or modify worker)

## 📸 Screenshots for Presentation

Recommended screenshots to capture:
1. Flutter app - Login screen
2. Flutter app - User home with SOS button
3. Flutter app - My Cases page showing case history
4. Flutter app - Volunteer dashboard with nearby cases
5. Portal landing page - Hero section with stats
6. Portal NGO dashboard - Real-time case feed
7. Hardhat console - Showing case creation events
8. Backend API response - Case creation JSON
9. Smart contract verification - On Etherscan (if deployed to testnet)

