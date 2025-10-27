const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🚀 Deploying all SafeHaven smart contracts...\n");

  const { ethers, network } = hre;

  // 1️⃣ Deploy RoleManagerContract
  const RoleManager = await ethers.getContractFactory("RoleManagerContract");
  const roleManager = await RoleManager.deploy();
  await roleManager.waitForDeployment();
  console.log(`✅ RoleManagerContract deployed at: ${await roleManager.getAddress()}`);

  // 2️⃣ Deploy CaseRegistry (depends on RoleManager)
  const CaseRegistry = await ethers.getContractFactory("CaseRegistry");
  const caseRegistry = await CaseRegistry.deploy(await roleManager.getAddress());
  await caseRegistry.waitForDeployment();
  console.log(`✅ CaseRegistry deployed at: ${await caseRegistry.getAddress()}`);

  // 3️⃣ Deploy CaseContract (depends on RoleManager)
  const CaseContract = await ethers.getContractFactory("CaseContract");
  const caseContract = await CaseContract.deploy(await roleManager.getAddress());
  await caseContract.waitForDeployment();
  console.log(`✅ CaseContract deployed at: ${await caseContract.getAddress()}`);

  // 4️⃣ Link CaseRegistry ↔ CaseContract
  const setCaseTx = await caseRegistry.setCaseContract(await caseContract.getAddress());
  await setCaseTx.wait();
  console.log("🔗 Linked CaseRegistry → CaseContract");

  const setRegistryTx = await caseContract.setRegistry(await caseRegistry.getAddress());
  await setRegistryTx.wait();
  console.log("🔗 Linked CaseContract → CaseRegistry");

  // 5️⃣ Deploy VolunteerReportContract (depends on RoleManager + CaseContract)
  const VolunteerReport = await ethers.getContractFactory("VolunteerReportContract");
  const volunteerReport = await VolunteerReport.deploy(
    await roleManager.getAddress(),
    await caseContract.getAddress()
  );
  await volunteerReport.waitForDeployment();
  console.log(`✅ VolunteerReportContract deployed at: ${await volunteerReport.getAddress()}`);

  console.log("\n📦 Preparing backend export files...");

  // -----------------------------
  // 🧩 AUTO-EXPORT SECTION
  // -----------------------------

  // Contract addresses
  const addresses = {
    network: network.name,
    ROLE_MANAGER_ADDRESS: await roleManager.getAddress(),
    CASE_REGISTRY_ADDRESS: await caseRegistry.getAddress(),
    CASE_CONTRACT_ADDRESS: await caseContract.getAddress(),
    VOLUNTEER_REPORT_ADDRESS: await volunteerReport.getAddress(),
  };

  const backendDir = path.resolve("../backend");
  fs.mkdirSync(backendDir, { recursive: true });

  const addressesPath = path.join(backendDir, "deployedAddresses.json");
  fs.writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));
  console.log(`💾 Saved deployed addresses to backend/deployedAddresses.json`);

  // ABI files
  const abiDir = path.join(backendDir, "abis");
  fs.mkdirSync(abiDir, { recursive: true });

  const contracts = [
    "RoleManagerContract",
    "CaseRegistry",
    "CaseContract",
    "VolunteerReportContract",
  ];

  for (const name of contracts) {
    const artifactPath = path.resolve(`artifacts/contracts/${name}.sol/${name}.json`);
    const artifact = JSON.parse(fs.readFileSync(artifactPath, "utf8"));
    fs.writeFileSync(`${abiDir}/${name}.json`, JSON.stringify(artifact.abi, null, 2));
    console.log(`✅ ABI exported for ${name}`);
  }

  console.log("\n🎯 Deployment complete!");
  console.log(`🌐 Network: ${network.name}`);
}

main().catch((err) => {
  console.error("❌ Deployment failed:", err);
  process.exit(1);
});
