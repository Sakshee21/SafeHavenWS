// routes/caseRoutes.js
const express = require("express");
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");
const CaseArtifact = require("../../smartcontracts/artifacts/contracts/CaseContract.sol/CaseContract.json").abi;
const RoleManagerArtifact = require("../../smartcontracts/artifacts/contracts/RoleManagerContract.sol/RoleManagerContract.json").abi;

const router = express.Router();

// -----------------------------
// Blockchain Connection Setup
// -----------------------------
const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

// Load deployed addresses exported by deployment script
const addressesPath = path.join(__dirname, "../deployedAddresses.json");
const deployed = JSON.parse(fs.readFileSync(addressesPath));
const caseContractAddress = deployed.CASE_CONTRACT_ADDRESS;

// Signer (Hardhat default account #0 if PRIVATE_KEY not provided)
const PRIVATE_KEY =
  process.env.PRIVATE_KEY ||
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const caseContract = new ethers.Contract(caseContractAddress, CaseArtifact, signer);
const roleManager = new ethers.Contract(deployed.ROLE_MANAGER_ADDRESS, RoleManagerArtifact, signer);

// -----------------------------
// Create Case
// -----------------------------
router.post("/create", async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    // Ensure the signer has the required 'User' role to create a case
    const hasUserRole = await roleManager.hasRole(await signer.getAddress(), "User");
    if (!hasUserRole) {
      const grantTx = await roleManager.assignRole(await signer.getAddress(), "User");
      await grantTx.wait();
    }

    const tx = await caseContract.createCase(latitude, longitude);
    await tx.wait();

    res.json({
      success: true,
      message: "🆘 Case created successfully!",
    });
  } catch (err) {
    console.error("Error creating case:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Health check for cases router
router.get("/ping", (req, res) => {
  res.json({ ok: true });
});

// -----------------------------
// Get Case by ID
// -----------------------------
router.get("/:id", async (req, res) => {
  try {
    const caseDetails = await caseContract.getCase(req.params.id);

    // Convert BigInt fields into strings for safe JSON serialization
    const formatted = {
      id: caseDetails.id.toString(),
      victim: caseDetails.victim,
      status: caseDetails.status.toString(),
      latitude: caseDetails.latitude,
      longitude: caseDetails.longitude,
      timestamp: caseDetails.timestamp.toString()
    };

    res.json({ success: true, caseDetails: formatted });
  } catch (err) {
    console.error("Error fetching case:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// -----------------------------
// Mark False Alarm
// -----------------------------
router.post("/markFalseAlarm/:id", async (req, res) => {
  try {
    const caseId = req.params.id;
    // Note: In production, this should use the victim's wallet address from request
    // For demo, we'll use the signer address (assuming it matches the victim)
    const tx = await caseContract.markFalseAlarm(caseId);
    await tx.wait();
    res.json({ success: true, message: "✅ Case marked as false alarm", txHash: tx.hash });
  } catch (err) {
    console.error("Error marking false alarm:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// -----------------------------
// Get Cases by User Address
// -----------------------------
router.get("/user/:address", async (req, res) => {
  try {
    const userAddress = req.params.address;
    const CaseRegistryArtifact = require("../../smartcontracts/artifacts/contracts/CaseRegistry.sol/CaseRegistry.json").abi;
    const caseRegistry = new ethers.Contract(deployed.CASE_REGISTRY_ADDRESS, CaseRegistryArtifact, provider);
    
    const caseIds = await caseRegistry.getCasesByVictim(userAddress);
    const cases = [];
    
    for (const id of caseIds) {
      try {
        const caseDetails = await caseContract.getCase(id);
        cases.push({
          id: caseDetails.id.toString(),
          victim: caseDetails.victim,
          status: caseDetails.status.toString(),
          latitude: caseDetails.latitude,
          longitude: caseDetails.longitude,
          timestamp: caseDetails.timestamp.toString(),
          assignedVolunteer: caseDetails.assignedVolunteer,
          acknowledgedBy: caseDetails.acknowledgedBy
        });
      } catch (e) {
        console.error(`Error fetching case ${id}:`, e);
      }
    }
    
    res.json({ success: true, cases });
  } catch (err) {
    console.error("Error fetching user cases:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});


module.exports = router;
