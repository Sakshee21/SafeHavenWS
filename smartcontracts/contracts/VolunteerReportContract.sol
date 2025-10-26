// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RoleManagerContract.sol";
import "./CaseContract.sol";

/*
 * VolunteerReportContract
 * - Volunteers must call acceptCase() before they can submit a report (actionCode 2).
 * - Anyone can call queryCase() (actionCode 3).
 * - Actions are logged on-chain for audit.
 */

contract VolunteerReportContract {
    RoleManagerContract public roleManager;
    CaseContract public caseContract;

    struct VolunteerLog {
        uint caseId;
        address volunteer; // for queries can be zero-address if caller is not a volunteer
        uint8 actionCode;  // 1 = accept, 2 = submit report, 3 = query
        uint timestamp;
    }

    // accepted volunteers for a case
    mapping(uint => address[]) public acceptedVolunteers;

    // logs per case
    mapping(uint => VolunteerLog[]) public logsByCase;

    event VolunteerAction(uint indexed caseId, address indexed actor, uint8 actionCode, uint timestamp);

    constructor(address _roleManager, address _caseContract) {
        roleManager = RoleManagerContract(_roleManager);
        caseContract = CaseContract(_caseContract);
    }

    // helper: check if volunteer is accepted for case
    function _isAccepted(uint _caseId, address _vol) internal view returns (bool) {
        address[] storage arr = acceptedVolunteers[_caseId];
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == _vol) return true;
        }
        return false;
    }

    // volunteers only modifier
    modifier onlyVolunteer() {
        require(roleManager.hasRole(msg.sender, "Volunteer"), "Access denied: not a volunteer");
        _;
    }

    /// Volunteer explicitly accepts the case. (actionCode 1)
    function acceptCase(uint _caseId) external onlyVolunteer {
        // ensure not accepted already
        require(!_isAccepted(_caseId, msg.sender), "Already accepted");
        acceptedVolunteers[_caseId].push(msg.sender);

        // push a log and emit
        logsByCase[_caseId].push(VolunteerLog({
            caseId: _caseId,
            volunteer: msg.sender,
            actionCode: 1,
            timestamp: block.timestamp
        }));

        emit VolunteerAction(_caseId, msg.sender, 1, block.timestamp);
    }

    /// Volunteer can submit a structured report only if they accepted previously (actionCode 2)
    function submitReport(uint _caseId) external onlyVolunteer {
        require(_isAccepted(_caseId, msg.sender), "Must accept case before submitting report");

        logsByCase[_caseId].push(VolunteerLog({
            caseId: _caseId,
            volunteer: msg.sender,
            actionCode: 2,
            timestamp: block.timestamp
        }));

        emit VolunteerAction(_caseId, msg.sender, 2, block.timestamp);
    }

    /// Query / follow-up: open for everyone (actionCode 3). If caller is a volunteer, their address is recorded; otherwise use msg.sender normally.
    function queryCase(uint _caseId) public {
        // record who called it (anyone)
        logsByCase[_caseId].push(VolunteerLog({
            caseId: _caseId,
            volunteer: msg.sender,
            actionCode: 3,
            timestamp: block.timestamp
        }));

        emit VolunteerAction(_caseId, msg.sender, 3, block.timestamp);
    }

    /// Get logs for a case
    function getLogsByCase(uint _caseId) public view returns (VolunteerLog[] memory) {
        return logsByCase[_caseId];
    }

    /// Get accepted volunteers for a case
    function getAcceptedVolunteers(uint _caseId) public view returns (address[] memory) {
        return acceptedVolunteers[_caseId];
    }
}
