// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RoleManagerContract.sol";
import "./CaseRegistry.sol";

/*
 * ------------------------------------------------------------
 * CaseContract
 * ------------------------------------------------------------
 * PURPOSE:
 *  - Handle SOS creation and marking false alarms.
 *  - Store victim location (latitude, longitude) at creation.
 *  - Automatically logs to CaseRegistry for indexing.
 * ------------------------------------------------------------
 */

contract CaseContract {
    RoleManagerContract public roleManager;
    CaseRegistry public caseRegistry;

    enum CaseStatus { Pending, Acknowledged, Escalated, Resolved, FalseAlarm }

    struct CaseDetails {
        uint id;
        address victim;
        CaseStatus status;
        string latitude;
        string longitude;
        uint timestamp;
        address assignedVolunteer;
        address acknowledgedBy;
    }

    mapping(uint => CaseDetails) public cases;
    uint public caseCounter;

    event CaseCreated(uint indexed caseId, address indexed victim, string latitude, string longitude);
    event CaseAcknowledged(uint indexed caseId, address indexed ngo);
    event CaseEscalated(uint indexed caseId);
    event CaseResolved(uint indexed caseId, address indexed ngo);
    event VolunteerAssigned(uint indexed caseId, address indexed volunteer);
    event CaseUpdated(uint indexed caseId, address indexed victim);

    constructor(address _roleManager) {
        roleManager = RoleManagerContract(_roleManager);
    }

    function setRegistry(address _registry) external {
        require(address(caseRegistry) == address(0), "Registry already linked");
        caseRegistry = CaseRegistry(_registry);
    }

    // Victim presses SOS → Case created with GPS
    function createCase(string memory _latitude, string memory _longitude) external {
        require(roleManager.hasRole(msg.sender, "User"), "Only registered user can create case");

        caseCounter++;
        cases[caseCounter] = CaseDetails({
            id: caseCounter,
            victim: msg.sender,
            status: CaseStatus.Pending,
            latitude: _latitude,
            longitude: _longitude,
            timestamp: block.timestamp,
            assignedVolunteer: address(0),
            acknowledgedBy: address(0)
        });

        caseRegistry.indexCase(msg.sender, caseCounter);
        emit CaseCreated(caseCounter, msg.sender, _latitude, _longitude);
    }

    function acknowledgeCase(uint _caseId) external {
        require(roleManager.hasRole(msg.sender, "NGO"), "Only NGO can acknowledge");
        CaseDetails storage c = cases[_caseId];
        require(c.id == _caseId && c.id != 0, "Case not found");
        require(c.status == CaseStatus.Pending, "Invalid state");
        c.status = CaseStatus.Acknowledged;
        c.acknowledgedBy = msg.sender;
        emit CaseAcknowledged(_caseId, msg.sender);
    }

    function assignVolunteer(uint _caseId, address _volunteer) external {
        require(roleManager.hasRole(msg.sender, "NGO"), "Only NGO can assign");
        require(roleManager.hasRole(_volunteer, "Volunteer"), "Target not volunteer");
        CaseDetails storage c = cases[_caseId];
        require(c.status == CaseStatus.Acknowledged || c.status == CaseStatus.Pending, "Invalid state");
        c.assignedVolunteer = _volunteer;
        emit VolunteerAssigned(_caseId, _volunteer);
    }

    function escalateCase(uint _caseId) external {
        require(roleManager.hasRole(msg.sender, "NGO"), "Only NGO can escalate");
        CaseDetails storage c = cases[_caseId];
        require(c.id == _caseId && c.id != 0, "Case not found");
        require(c.status == CaseStatus.Pending || c.status == CaseStatus.Acknowledged, "Invalid state");
        c.status = CaseStatus.Escalated;
        emit CaseEscalated(_caseId);
    }

    function markResolved(uint _caseId) external {
        require(roleManager.hasRole(msg.sender, "NGO"), "Only NGO can resolve");
        CaseDetails storage c = cases[_caseId];
        require(c.id == _caseId && c.id != 0, "Case not found");
        require(c.status != CaseStatus.Resolved, "Already resolved");
        c.status = CaseStatus.Resolved;
        emit CaseResolved(_caseId, msg.sender);
    }

    // Only the victim who created the case can mark it as false alarm
    function markFalseAlarm(uint _caseId) external {
        CaseDetails storage c = cases[_caseId];
        require(c.id == _caseId && c.id != 0, "Case not found");
        require(c.victim == msg.sender, "Only case creator can mark false alarm");
        require(c.status != CaseStatus.Resolved && c.status != CaseStatus.FalseAlarm, "Cannot mark resolved or already false alarm");
        c.status = CaseStatus.FalseAlarm;
        emit CaseUpdated(_caseId, msg.sender);
    }

    function getCase(uint _caseId) public view returns (CaseDetails memory) {
        return cases[_caseId];
    }
}
