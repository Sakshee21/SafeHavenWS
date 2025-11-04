// backend/routes/cases_extras.js
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

function toRad(v) { return (v * Math.PI) / 180; }
function haversineKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat/2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon/2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

router.get("/nearby", async (req, res) => {
  try {
    const lat = parseFloat(req.query.lat);
    const lng = parseFloat(req.query.lng);
    const radiusKm = parseFloat(req.query.radiusKm || "5");
    if (Number.isNaN(lat) || Number.isNaN(lng)) {
      return res.status(400).json({ success: false, error: "lat and lng required" });
    }
    const total = Number(await caseContract.caseCounter());
    const results = [];
    for (let i = 1; i <= total; i++) {
      const c = await caseContract.getCase(i);
      const cLat = parseFloat(c.latitude);
      const cLng = parseFloat(c.longitude);
      if (Number.isNaN(cLat) || Number.isNaN(cLng)) continue;
      const dist = haversineKm(lat, lng, cLat, cLng);
      if (dist <= radiusKm) {
        results.push({ id: Number(c.id), lat: c.latitude, lng: c.longitude, status: Number(c.status), distanceKm: dist });
      }
    }
    res.json({ success: true, count: results.length, cases: results });
  } catch (err) {
    console.error("/cases/nearby error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;


