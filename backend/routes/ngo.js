// backend/routes/ngo.js
const express = require("express");
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

const router = express.Router();

// Blockchain setup
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || "http://127.0.0.1:8545");
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const addressesPath = path.join(__dirname, "../deployedAddresses.json");
const deployed = JSON.parse(fs.readFileSync(addressesPath));

const CaseArtifact = require("../../smartcontracts/artifacts/contracts/CaseContract.sol/CaseContract.json").abi;
const RoleManagerArtifact = require("../../smartcontracts/artifacts/contracts/RoleManagerContract.sol/RoleManagerContract.json").abi;

const caseContract = new ethers.Contract(deployed.CASE_CONTRACT_ADDRESS, CaseArtifact, signer);
const roleManager = new ethers.Contract(deployed.ROLE_MANAGER_ADDRESS, RoleManagerArtifact, signer);

// Ensure backend signer has NGO role (best-effort)
async function ensureNgoRole() {
  const addr = await signer.getAddress();
  const has = await roleManager.hasRole(addr, "NGO");
  if (!has) {
    const tx = await roleManager.assignRole(addr, "NGO");
    await tx.wait();
  }
}

// Utility: read all cases and filter active
async function fetchAllCases() {
  const total = await caseContract.caseCounter();
  const items = [];
  for (let i = 1n; i <= total; i++) {
    const c = await caseContract.getCase(i);
    items.push({
      id: Number(c.id),
      victim: c.victim,
      status: Number(c.status),
      latitude: c.latitude,
      longitude: c.longitude,
      timestamp: Number(c.timestamp),
      assignedVolunteer: c.assignedVolunteer,
      acknowledgedBy: c.acknowledgedBy,
    });
  }
  return items;
}

router.get("/cases", async (req, res) => {
  try {
    const all = await fetchAllCases();
    const active = all.filter(x => x.status !== 3); // not Resolved
    res.json({ success: true, cases: active });
  } catch (err) {
    console.error("/ngo/cases error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post("/acknowledge/:id", async (req, res) => {
  try {
    await ensureNgoRole();
    const id = Number(req.params.id);
    const tx = await caseContract.acknowledgeCase(id);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error("acknowledge error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post("/resolve/:id", async (req, res) => {
  try {
    await ensureNgoRole();
    const id = Number(req.params.id);
    const tx = await caseContract.markResolved(id);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error("resolve error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post("/escalate/:id", async (req, res) => {
  try {
    await ensureNgoRole();
    const id = Number(req.params.id);
    const tx = await caseContract.escalateCase(id);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error("escalate error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post("/assign/:id", async (req, res) => {
  try {
    await ensureNgoRole();
    const id = Number(req.params.id);
    const { volunteer } = req.body;
    if (!volunteer) return res.status(400).json({ success: false, error: "volunteer required" });
    const tx = await caseContract.assignVolunteer(id, volunteer);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error("assign error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
