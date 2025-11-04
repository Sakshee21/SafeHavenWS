const fs = require("fs");
const path = require("path");

async function main() {
  const { ethers } = require("hardhat");
  const addresses = JSON.parse(
    fs.readFileSync(path.resolve(__dirname, "../../backend/deployedAddresses.json"), "utf8")
  );

  const roleManager = await ethers.getContractAt(
    "RoleManagerContract",
    addresses.ROLE_MANAGER_ADDRESS
  );

  const [signer0] = await ethers.getSigners();
  const target = process.env.TARGET || signer0.address;
  console.log("Granting 'User' role to:", target);

  const has = await roleManager.hasRole(target, "User");
  if (!has) {
    const tx = await roleManager.assignRole(target, "User");
    await tx.wait();
    console.log("Granted.");
  } else {
    console.log("Already has role.");
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});


