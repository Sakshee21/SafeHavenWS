// backend/routes/case.js
const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");

// Load contract addresses
const addresses = JSON.parse(
  fs.readFileSync(path.join(__dirname, "../deployedAddresses.json"))
);

// Load ABI for CaseContract
const caseABI = require("../../smartcontracts/artifacts/contracts/CaseContract.sol/CaseContract.json").abi;

// Provider and Wallet
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

// Contract instance
const caseContract = new ethers.Contract(
  addresses.CASE_CONTRACT_ADDRESS,
  caseABI,
  wallet
);

// -----------------------
// 🧪 Test Route
// -----------------------
router.get("/test", async (req, res) => {
  try {
    const caseCount = await caseContract.caseCounter();
    res.json({
      success: true,
      message: "Connected to CaseContract successfully!",
      caseContractAddress: addresses.CASE_CONTRACT_ADDRESS,
      totalCases: Number(caseCount),
    });
  } catch (err) {
    console.error("Error in /test route:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// -----------------------
// 🎯 Create new case (victim SOS)
// -----------------------
router.post("/create", async (req, res) => {
  try {
    const { latitude, longitude } = req.body;

    const tx = await caseContract.createCase(latitude, longitude);
    await tx.wait();

    const caseCount = await caseContract.caseCounter();
    res.json({
      success: true,
      message: `Case created successfully!`,
      caseId: Number(caseCount),
      txHash: tx.hash,
    });
  } catch (err) {
    console.error("Error creating case:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// -----------------------
// 📋 Get a case by ID
// -----------------------
router.get("/:id", async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const details = await caseContract.getCase(id);

    res.json({
      success: true,
      caseDetails: {
        id: Number(details.id),
        victim: details.victim,
        status: details.status,
        latitude: details.latitude,
        longitude: details.longitude,
        timestamp: Number(details.timestamp),
      },
    });
  } catch (err) {
    console.error("Error fetching case:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
