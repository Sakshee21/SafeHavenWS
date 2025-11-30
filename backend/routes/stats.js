// backend/routes/stats.js
const express = require("express");
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

const router = express.Router();

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || "http://127.0.0.1:8545");
const PRIVATE_KEY = process.env.PRIVATE_KEY || "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const addressesPath = path.join(__dirname, "../deployedAddresses.json");
const deployed = JSON.parse(fs.readFileSync(addressesPath));
const CaseArtifact = require("../../smartcontracts/artifacts/contracts/CaseContract.sol/CaseContract.json").abi;
const caseContract = new ethers.Contract(deployed.CASE_CONTRACT_ADDRESS, CaseArtifact, signer);

async function handleStats(req, res) {
  try {
    const total = Number(await caseContract.caseCounter());
    let open = 0, acknowledged = 0, escalated = 0, resolved = 0;
    for (let i = 1; i <= total; i++) {
      const c = await caseContract.getCase(i);
      const s = Number(c.status);
      if (s === 0) open++; // Pending
      else if (s === 1) acknowledged++;
      else if (s === 2) escalated++;
      else if (s === 3) resolved++;
    }
    res.json({ success: true, total, open, acknowledged, escalated, resolved });
  } catch (err) {
    console.error("/stats error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
}

router.get("/", handleStats);
router.get("", handleStats);

module.exports = router;


