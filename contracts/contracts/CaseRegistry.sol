// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CaseContract.sol";
import "./RoleManagerContract.sol";

/*
 * ------------------------------------------------------------
 * CaseRegistry
 * ------------------------------------------------------------
 * PURPOSE:
 *  - Keep mapping of cases by victims.
 *  - Acts as a lightweight index for UI and off-chain systems.
 * ------------------------------------------------------------
 */

contract CaseRegistry {
    RoleManagerContract public roleManager;
    CaseContract public caseContract;
    address public owner;

    mapping(address => uint[]) public casesByVictim;

    event CaseIndexed(uint indexed caseId, address indexed victim);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _roleManager) {
        roleManager = RoleManagerContract(_roleManager);
        owner = msg.sender;
    }

    function setCaseContract(address _caseContract) external onlyOwner {
        caseContract = CaseContract(_caseContract);
    }

    function indexCase(address _victim, uint _caseId) external {
        require(msg.sender == address(caseContract), "Only CaseContract can call");
        casesByVictim[_victim].push(_caseId);
        emit CaseIndexed(_caseId, _victim);
    }

    function getCasesByVictim(address _victim) external view returns (uint[] memory) {
        return casesByVictim[_victim];
    }
}
