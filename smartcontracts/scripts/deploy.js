const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying all SafeHaven smart contracts...\n");

  const { ethers } = hre;

  const RoleManager = await ethers.getContractFactory("RoleManagerContract");
  const roleManager = await RoleManager.deploy();
  await roleManager.waitForDeployment();
  console.log(`✅ RoleManagerContract deployed at: ${await roleManager.getAddress()}`);

  const CaseRegistry = await ethers.getContractFactory("CaseRegistry");
  const caseRegistry = await CaseRegistry.deploy(await roleManager.getAddress());
  await caseRegistry.waitForDeployment();
  console.log(`✅ CaseRegistry deployed at: ${await caseRegistry.getAddress()}`);

  const CaseContract = await ethers.getContractFactory("CaseContract");
  const caseContract = await CaseContract.deploy(await roleManager.getAddress());
  await caseContract.waitForDeployment();
  console.log(`✅ CaseContract deployed at: ${await caseContract.getAddress()}`);

  const setCaseTx = await caseRegistry.setCaseContract(await caseContract.getAddress());
  await setCaseTx.wait();
  console.log("🔗 Linked CaseRegistry → CaseContract");

  const setRegistryTx = await caseContract.setRegistry(await caseRegistry.getAddress());
  await setRegistryTx.wait();
  console.log("🔗 Linked CaseContract → CaseRegistry");

  const VolunteerReport = await ethers.getContractFactory("VolunteerReportContract");
  const volunteerReport = await VolunteerReport.deploy(
    await roleManager.getAddress(),
    await caseContract.getAddress()
  );
  await volunteerReport.waitForDeployment();
  console.log(`✅ VolunteerReportContract deployed at: ${await volunteerReport.getAddress()}`);

  console.log("\n🎯 Deployment complete!");
}

main().catch((err) => {
  console.error("❌ Deployment failed:", err);
  process.exit(1);
});
