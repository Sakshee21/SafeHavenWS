// ==============================
// routes/contracts.js
// ==============================
const express = require("express");
const router = express.Router();
const fs = require("fs");
const path = require("path");
const { ethers } = require("ethers");

// --------------------------------------
// Load deployed contract address
// --------------------------------------
const addressesPath = path.join(__dirname, "../deployedAddresses.json");
const addresses = JSON.parse(fs.readFileSync(addressesPath));

// --------------------------------------
// Load ABI (RoleManagerContract ABI)
// --------------------------------------
const roleManagerABI = require("../../smartcontracts/artifacts/contracts/RoleManagerContract.sol/RoleManagerContract.json").abi;

// --------------------------------------
// Connect to Hardhat / Ganache RPC
// --------------------------------------
const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

//  Use any private key from Hardhat/Ganache
const PRIVATE_KEY = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

// --------------------------------------
// Instantiate the contract
// --------------------------------------
const roleManager = new ethers.Contract(
  addresses.ROLE_MANAGER_ADDRESS,
  roleManagerABI,
  wallet
);

// --------------------------------------
// TEST ROUTE — checks blockchain connection
// --------------------------------------
router.get("/test", async (req, res) => {
  try {
    // just query roles of the current wallet
    const roles = await roleManager.getRoles(wallet.address);

    res.json({
      success: true,
      message: "Connected to blockchain successfully!",
      connectedAccount: wallet.address,
      roleManagerAddress: addresses.ROLE_MANAGER_ADDRESS,
      roles,
    });
  } catch (err) {
    console.error("Error connecting to contract:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// --------------------------------------
// Assign a new role to any user
// --------------------------------------
router.post("/assign", async (req, res) => {
  try {
    const { user, role } = req.body;
    if (!user || !role) {
      return res.status(400).json({ success: false, error: "User and role are required" });
    }

    const tx = await roleManager.assignRole(user, role);
    await tx.wait();

    res.json({
      success: true,
      message: `Assigned role '${role}' to ${user}`,
      txHash: tx.hash,
    });
  } catch (err) {
    console.error("Role assignment error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// --------------------------------------
// Check if a user has a role
// --------------------------------------
router.get("/hasRole/:address/:role", async (req, res) => {
  try {
    const { address, role } = req.params;
    const result = await roleManager.hasRole(address, role);
    res.json({
      address,
      role,
      hasRole: result,
    });
  } catch (err) {
    console.error("Role check error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// --------------------------------------
// Get all roles for a user
// --------------------------------------
router.get("/getRoles/:address", async (req, res) => {
  try {
    const { address } = req.params;
    const roles = await roleManager.getRoles(address);
    res.json({
      address,
      roles,
    });
  } catch (err) {
    console.error("Get roles error:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
