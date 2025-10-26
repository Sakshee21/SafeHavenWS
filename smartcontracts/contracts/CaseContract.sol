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

    enum CaseStatus { Created, FalseAlarm, Resolved }

    struct CaseDetails {
        uint id;
        address victim;
        CaseStatus status;
        string latitude;
        string longitude;
        uint timestamp;
    }

    mapping(uint => CaseDetails) public cases;
    uint public caseCounter;

    event CaseCreated(uint indexed caseId, address indexed victim, string latitude, string longitude);
    event CaseMarkedFalse(uint indexed caseId, address indexed victim);

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
            status: CaseStatus.Created,
            latitude: _latitude,
            longitude: _longitude,
            timestamp: block.timestamp
        });

        caseRegistry.indexCase(msg.sender, caseCounter);
        emit CaseCreated(caseCounter, msg.sender, _latitude, _longitude);
    }

    // Victim presses "False Alarm"
    function markAsFalse(uint _caseId) external {
        CaseDetails storage c = cases[_caseId];
        require(c.victim == msg.sender, "Only victim can mark false");
        require(c.status == CaseStatus.Created, "Not active");
        c.status = CaseStatus.FalseAlarm;
        emit CaseMarkedFalse(_caseId, msg.sender);
    }

    function getCase(uint _caseId) public view returns (CaseDetails memory) {
        return cases[_caseId];
    }
}
