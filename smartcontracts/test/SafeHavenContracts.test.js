const { expect } = require("chai");
const { ethers } = require("hardhat");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("🚨 SafeHaven Blockchain Suite", function () {
  let owner, user1, volunteer1, dualRole, outsider;
  let roleManager, caseRegistry, caseContract, volunteerReport;

  before(async function () {
    [owner, user1, volunteer1, dualRole, outsider] = await ethers.getSigners();

    // ----------------------------
    // DEPLOYMENT PHASE
    // ----------------------------
    const RoleManager = await ethers.getContractFactory("RoleManagerContract");
    roleManager = await RoleManager.deploy();
    await roleManager.waitForDeployment();

    const CaseRegistry = await ethers.getContractFactory("CaseRegistry");
    caseRegistry = await CaseRegistry.deploy(await roleManager.getAddress());
    await caseRegistry.waitForDeployment();

    const CaseContract = await ethers.getContractFactory("CaseContract");
    caseContract = await CaseContract.deploy(await roleManager.getAddress());
    await caseContract.waitForDeployment();

    await (await caseRegistry.setCaseContract(await caseContract.getAddress())).wait();
    await (await caseContract.setRegistry(await caseRegistry.getAddress())).wait();

    const VolunteerReport = await ethers.getContractFactory("VolunteerReportContract");
    volunteerReport = await VolunteerReport.deploy(
      await roleManager.getAddress(),
      await caseContract.getAddress()
    );
    await volunteerReport.waitForDeployment();
  });

  // --------------------------------------------------
  // ROLE ASSIGNMENT TESTS
  // --------------------------------------------------
  it("should assign multiple roles to same address", async function () {
    await roleManager.assignRole(dualRole.address, "User");
    await roleManager.assignRole(dualRole.address, "Volunteer");

    const isUser = await roleManager.hasRole(dualRole.address, "User");
    const isVolunteer = await roleManager.hasRole(dualRole.address, "Volunteer");

    expect(isUser).to.be.true;
    expect(isVolunteer).to.be.true;
  });

  it("should assign User and Volunteer roles separately", async function () {
    await roleManager.assignRole(user1.address, "User");
    await roleManager.assignRole(volunteer1.address, "Volunteer");

    expect(await roleManager.hasRole(user1.address, "User")).to.be.true;
    expect(await roleManager.hasRole(volunteer1.address, "Volunteer")).to.be.true;
  });

  // --------------------------------------------------
  // CASE CREATION & REGISTRY
  // --------------------------------------------------
  it("only a User can create a case", async function () {
    const lat = "28.6139";
    const lon = "77.2090";

    // user1 has role 'User' → should work
    await expect(caseContract.connect(user1).createCase(lat, lon))
      .to.emit(caseContract, "CaseCreated")
      .withArgs(1, user1.address, lat, lon);

    // outsider does NOT have role 'User' → should fail
    await expect(caseContract.connect(outsider).createCase(lat, lon))
      .to.be.revertedWith("Only registered user can create case");
  });

  it("created case should be indexed in CaseRegistry", async function () {
    const cases = await caseRegistry.getCasesByVictim(user1.address);
    expect(cases.length).to.equal(1);
    expect(cases[0]).to.equal(1n);
  });

  it("only the victim can mark a case as false alarm", async function () {
    await expect(caseContract.connect(user1).markAsFalse(1))
      .to.emit(caseContract, "CaseMarkedFalse")
      .withArgs(1, user1.address);

    // outsider cannot mark someone else's case false
    await expect(caseContract.connect(outsider).markAsFalse(1))
      .to.be.revertedWith("Only victim can mark false");
  });

  // --------------------------------------------------
  // VOLUNTEER REPORT TESTS
  // --------------------------------------------------
  it(" volunteers must accept before submitting report", async function () {
    // volunteer1 is Volunteer but hasn’t accepted yet
    await expect(volunteerReport.connect(volunteer1).submitReport(1))
      .to.be.revertedWith("Must accept case before submitting report");

    // volunteer1 accepts the case
    await expect(volunteerReport.connect(volunteer1).acceptCase(1))
      .to.emit(volunteerReport, "VolunteerAction")
      .withArgs(1, volunteer1.address, 1, anyValue); // accept action

    // now submit report should succeed
    await expect(volunteerReport.connect(volunteer1).submitReport(1))
      .to.emit(volunteerReport, "VolunteerAction")
      .withArgs(1, volunteer1.address, 2, anyValue);
  });

  it("same volunteer cannot accept same case twice", async function () {
    await expect(volunteerReport.connect(volunteer1).acceptCase(1))
      .to.be.revertedWith("Already accepted");
  });

  it("dual-role user can also act as volunteer", async function () {
    // user1 created a case; now dualRole (User+Volunteer) accepts it
    await expect(volunteerReport.connect(dualRole).acceptCase(1))
      .to.emit(volunteerReport, "VolunteerAction")
      .withArgs(1, dualRole.address, 1, anyValue);
  });

  it("any address can query case (even outsiders)", async function () {
    await expect(volunteerReport.connect(outsider).queryCase(1))
      .to.emit(volunteerReport, "VolunteerAction")
      .withArgs(1, outsider.address, 3, anyValue);
  });

  it("should store and retrieve all volunteer logs correctly", async function () {
    const logs = await volunteerReport.getLogsByCase(1);
    expect(logs.length).to.be.greaterThan(0);

    const accepted = await volunteerReport.getAcceptedVolunteers(1);
    expect(accepted).to.include(volunteer1.address);
    expect(accepted).to.include(dualRole.address);
  });
});
