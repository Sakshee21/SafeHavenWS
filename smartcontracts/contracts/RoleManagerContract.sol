// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * ------------------------------------------------------------
 * RoleManagerContract
 * ------------------------------------------------------------
 * PURPOSE:
 *  - Assign and verify user roles ("User", "Volunteer").
 *  - Support multi-role users (can be both User & Volunteer).
 * ------------------------------------------------------------
 */

contract RoleManagerContract {
    mapping(address => string[]) private roles;

    event RoleAssigned(address indexed user, string role);

    // Assign a role to a user (can have multiple roles)
    function assignRole(address _user, string memory _role) external {
        require(bytes(_role).length > 0, "Invalid role");
        roles[_user].push(_role);
        emit RoleAssigned(_user, _role);
    }

    // Check if a user has a specific role
    function hasRole(address _user, string memory _role) public view returns (bool) {
        string[] memory userRoles = roles[_user];
        for (uint i = 0; i < userRoles.length; i++) {
            if (keccak256(bytes(userRoles[i])) == keccak256(bytes(_role))) {
                return true;
            }
        }
        return false;
    }

    // Get all roles of a user
    function getRoles(address _user) external view returns (string[] memory) {
        return roles[_user];
    }
}
