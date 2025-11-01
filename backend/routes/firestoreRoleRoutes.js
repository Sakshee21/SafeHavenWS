// backend/routes/firestoreRoleRoutes.js
const express = require("express");
const { ethers } = require("ethers");
const admin = require("firebase-admin");
const path = require("path");
const RoleManagerArtifact = require("../abis/RoleManagerContract.json");

const router = express.Router();

// -----------------------------
// FIREBASE ADMIN INITIALIZATION
// -----------------------------
if (!admin.apps.length) {
  const serviceAccountPath = path.join(__dirname, "../serviceAccountKey.json");
  const serviceAccount = require(serviceAccountPath);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}
const db = admin.firestore();

// -----------------------------
// BLOCKCHAIN SETUP
// -----------------------------
// -----------------------------
// BLOCKCHAIN SETUP (Fixed for Ethers v6)
// -----------------------------
const { JsonRpcProvider, Network } = ethers;

// Define the Hardhat network explicitly
const hardhatNetwork = new Network("hardhat", 31337);

// Create the provider using URL + network object
const provider = new JsonRpcProvider("http://127.0.0.1:8545", hardhatNetwork);


// Load contract address (from env or JSON)
const deployedAddresses = require("../deployedAddresses.json");
const roleManagerAddress =
  process.env.ROLE_MANAGER_ADDRESS || deployedAddresses.RoleManagerContract;

// Sanity checks
if (!roleManagerAddress) {
  console.error("❌ No RoleManagerContract address found!");
  throw new Error("Missing contract address (check .env or deployedAddresses.json)");
}
if (!RoleManagerArtifact.abi) {
  console.error("❌ ABI not found in RoleManagerArtifact!");
  throw new Error("Invalid RoleManagerContract ABI file");
}

console.log("🧩 Using RoleManagerContract at:", roleManagerAddress);

let signer, roleManagerContract;

// Initialize signer + contract safely
(async () => {
  try {
    // Use Hardhat default account private key (account[0])
    const defaultPrivateKey =
      "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"; // Hardhat default #0

    signer = new ethers.Wallet(defaultPrivateKey, provider);

    roleManagerContract = new ethers.Contract(
      roleManagerAddress,
      RoleManagerArtifact.abi,
      signer
    );

    console.log("✅ RoleManager contract connected successfully using wallet:", signer.address);
  } catch (err) {
    console.error("❌ Failed to connect RoleManagerContract:", err);
  }
})();


// -----------------------------
// ROUTE: Assign Roles from Firestore
// -----------------------------

router.get("/assignFromFirestore/:uid", async (req, res) => {
  try {
    const { uid } = req.params;

    const docRef = db.collection("users").doc(uid);
    const doc = await docRef.get();

    if (!doc.exists)
      return res
        .status(404)
        .json({ success: false, error: "User not found in Firestore" });

    const user = doc.data();

    if (!user.address)
      return res
        .status(400)
        .json({ success: false, error: "User has no blockchain address" });

    if (!roleManagerContract)
      return res
        .status(500)
        .json({ success: false, error: "Contract not initialized yet" });

    console.log("📜 Firestore user data:", user);
    console.log("📦 Address type:", typeof user.address);
    console.log("📦 Address value:", user.address);

    // ✅ Merge both 'roles' and 'role' if both exist
    let roles = [];
    if (Array.isArray(user.roles)) roles = roles.concat(user.roles);
    if (Array.isArray(user.role)) roles = roles.concat(user.role);

    // ✅ Deduplicate and lowercase all roles
    roles = [
    ...new Set(
        roles.map(r => 
        r.charAt(0).toUpperCase() + r.slice(1).toLowerCase()
        )
    ),
    ];

    if (roles.length === 0)
      return res
        .status(400)
        .json({ success: false, error: "User has no roles to assign" });

    // ✅ Validate & normalize the blockchain address
    let targetAddress = user.address.trim();

    if (!ethers.isAddress(targetAddress)) {
      console.error("❌ Invalid Ethereum address in Firestore:", targetAddress);
      return res
        .status(400)
        .json({ success: false, error: "Invalid address format" });
    }

    targetAddress = ethers.getAddress(targetAddress); // checksum format

    // ✅ Assign each unique role on-chain
    // ✅ Assign each unique role on-chain (nonce-safe version)
    const results = [];
    let baseNonce = await signer.getNonce(); // start from current nonce

    for (let i = 0; i < roles.length; i++) {
    const role = roles[i];
    const currentNonce = baseNonce + i; // increment manually
    console.log(`🔹 Assigning ${role} to ${targetAddress}...`);
    console.log(`Using nonce: ${currentNonce}`);

    const tx = await roleManagerContract.assignRole(
        targetAddress,
        ethers.encodeBytes32String(role),
        { nonce: currentNonce }  // ✅ explicitly set incremented nonce
    );

    await tx.wait();
    results.push(role);
    console.log(`✅ Successfully assigned ${role}`);
    }


    // ✅ Response
    res.json({
      success: true,
      message: `Roles [${results.join(", ")}] assigned to ${targetAddress}`,
    });
  } catch (err) {
    console.error("❌ Error assigning role:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});


module.exports = router;
