// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SocialRecoveryWallet {
    using ECDSA for bytes32;

    address public owner;
    uint256 public nonce;
    uint256 public threshold;
    uint256 public recoveryDelay = 48 hours;

    mapping(bytes32 => bool) public guardians; // keccak256(guardian) => active
    uint256 public guardianCount;

    struct RecoveryRequest {
        address proposedOwner;
        uint256 approvals;
        uint256 initiatedAt;
        bool executed;
        mapping(bytes32 => bool) approved;
    }
    RecoveryRequest public activeRecovery;
    bool public recoveryActive;

    event RecoveryInitiated(address indexed proposedOwner, uint256 at);
    event RecoveryApproved(address indexed guardian, uint256 approvals);
    event RecoveryExecuted(address indexed newOwner);
    event GuardianAdded(bytes32 indexed guardianHash);
    event Executed(address indexed to, uint256 value, bytes data);

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }

    constructor(address[] memory guardianAddresses, uint256 threshold_) {
        owner = msg.sender;
        threshold = threshold_;
        for (uint i = 0; i < guardianAddresses.length; i++) {
            bytes32 h = keccak256(abi.encodePacked(guardianAddresses[i]));
            guardians[h] = true;
            emit GuardianAdded(h);
        }
        guardianCount = guardianAddresses.length;
    }

    function execute(address to, uint256 value, bytes calldata data, bytes calldata sig) external returns (bytes memory) {
        bytes32 hash = keccak256(abi.encodePacked(address(this), nonce++, to, value, data)).toEthSignedMessageHash();
        require(hash.recover(sig) == owner, "Invalid sig");
        (bool ok, bytes memory result) = to.call{value: value}(data);
        require(ok, "Call failed");
        emit Executed(to, value, data);
        return result;
    }

    function initiateRecovery(address proposedOwner) external {
        bytes32 guardianHash = keccak256(abi.encodePacked(msg.sender));
        require(guardians[guardianHash], "Not guardian");
        recoveryActive = true;
        activeRecovery.proposedOwner = proposedOwner;
        activeRecovery.approvals = 1;
        activeRecovery.initiatedAt = block.timestamp;
        activeRecovery.approved[guardianHash] = true;
        emit RecoveryInitiated(proposedOwner, block.timestamp);
    }

    function approveRecovery() external {
        require(recoveryActive, "No active recovery");
        bytes32 guardianHash = keccak256(abi.encodePacked(msg.sender));
        require(guardians[guardianHash], "Not guardian");
        require(!activeRecovery.approved[guardianHash], "Already approved");
        activeRecovery.approved[guardianHash] = true;
        activeRecovery.approvals++;
        emit RecoveryApproved(msg.sender, activeRecovery.approvals);
    }

    function executeRecovery() external {
        require(recoveryActive, "No active recovery");
        require(activeRecovery.approvals >= threshold, "Not enough approvals");
        require(block.timestamp >= activeRecovery.initiatedAt + recoveryDelay, "Time-lock active");
        owner = activeRecovery.proposedOwner;
        recoveryActive = false;
        emit RecoveryExecuted(owner);
    }

    function cancelRecovery() external onlyOwner { recoveryActive = false; }
    receive() external payable {}
}