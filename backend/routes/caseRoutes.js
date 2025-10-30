// routes/caseRoutes.js
const express = require("express");
const { ethers } = require("ethers");
const CaseArtifact = require("../../smartcontracts/artifacts/contracts/CaseContract.sol/CaseContract.json").abi;

const router = express.Router();

// -----------------------------
// Blockchain Connection Setup
// -----------------------------
const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

// Replace with your deployed contract address
const caseContractAddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

// -----------------------------
// Create Case
// -----------------------------
router.post("/create", async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    // signer fetched dynamically (only for write ops)
    const signer = await provider.getSigner(0);
    const caseContract = new ethers.Contract(
      caseContractAddress,
      CaseArtifact.abi,
      signer
    );

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


module.exports = router;
