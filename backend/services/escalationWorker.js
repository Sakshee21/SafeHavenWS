// backend/services/escalationWorker.js
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || "http://127.0.0.1:8545");
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const addressesPath = path.join(__dirname, "../deployedAddresses.json");
const deployed = JSON.parse(fs.readFileSync(addressesPath));

const CaseArtifact = require("../../smartcontracts/artifacts/contracts/CaseContract.sol/CaseContract.json").abi;
const RoleManagerArtifact = require("../../smartcontracts/artifacts/contracts/RoleManagerContract.sol/RoleManagerContract.json").abi;

const caseContract = new ethers.Contract(deployed.CASE_CONTRACT_ADDRESS, CaseArtifact, signer);
const roleManager = new ethers.Contract(deployed.ROLE_MANAGER_ADDRESS, RoleManagerArtifact, signer);

const THIRTY_MINUTES = 30 * 60 * 1000;
const SIXTY_MINUTES = 60 * 60 * 1000;

async function ensureNgoRole() {
  const addr = await signer.getAddress();
  const has = await roleManager.hasRole(addr, "NGO");
  if (!has) {
    const tx = await roleManager.assignRole(addr, "NGO");
    await tx.wait();
  }
}

async function checkAndEscalate() {
  try {
    await ensureNgoRole();
    const total = Number(await caseContract.caseCounter());
    const now = Date.now();

    for (let i = 1; i <= total; i++) {
      const c = await caseContract.getCase(i);
      const status = Number(c.status);
      const timestamp = Number(c.timestamp) * 1000;
      const age = now - timestamp;

      // Pending > 60 minutes → escalate
      if (status === 0 && age > SIXTY_MINUTES) {
        console.log(`🚨 Auto-escalating case #${i} (pending > 60min)`);
        const tx = await caseContract.escalateCase(i);
        await tx.wait();
        continue;
      }

      // Acknowledged > 60 minutes → escalate
      if (status === 1 && age > SIXTY_MINUTES) {
        console.log(`🚨 Auto-escalating case #${i} (acknowledged > 60min)`);
        const tx = await caseContract.escalateCase(i);
        await tx.wait();
      }
    }
  } catch (err) {
    console.error("Escalation worker error:", err);
  }
}

let intervalId = null;

function start() {
  if (intervalId) return;
  console.log("⏰ Escalation worker started (checking every minute)");
  checkAndEscalate();
  intervalId = setInterval(checkAndEscalate, 60 * 1000);
}

function stop() {
  if (intervalId) {
    clearInterval(intervalId);
    intervalId = null;
    console.log("⏰ Escalation worker stopped");
  }
}

module.exports = { start, stop };

