// backend/routes/volunteer.js
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

const VolunteerReportArtifact = require("../../smartcontracts/artifacts/contracts/VolunteerReportContract.sol/VolunteerReportContract.json").abi;
const volunteerReport = new ethers.Contract(deployed.VOLUNTEER_REPORT_ADDRESS, VolunteerReportArtifact, signer);

router.post("/accept/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    // Note: Volunteer must connect with their own wallet; backend uses default signer for demo
    const tx = await volunteerReport.acceptCase(id);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error("accept error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post("/report/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { text } = req.body;
    // VolunteerReportContract.submitReport expects caseId only
    const tx = await volunteerReport.submitReport(id);
    await tx.wait();
    res.json({ success: true, txHash: tx.hash });
  } catch (err) {
    console.error("report error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;

