// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, euint16, euint32, externalEuint8, externalEuint16, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title EncryptMultipleValues
 * @notice Demonstrates how to handle multiple encrypted values in a single transaction
 * @dev Shows:
 *   - Multiple encrypted inputs in one function
 *   - Different encrypted types (euint8, euint16, euint32)
 *   - Efficient permission management
 *   - Batch operations on encrypted data
 */
contract EncryptMultipleValues is ZamaEthereumConfig {
    // Store multiple encrypted attributes for each user
    struct EncryptedProfile {
        euint8 age;
        euint16 score;
        euint32 balance;
        bool initialized;
    }

    mapping(address => EncryptedProfile) private _profiles;

    event ProfileCreated(address indexed user);
    event ProfileUpdated(address indexed user);

    /**
     * @notice Creates a profile with multiple encrypted values
     * @dev Demonstrates handling multiple encrypted inputs in one transaction
     * @param inputAge Encrypted age (8-bit)
     * @param inputScore Encrypted score (16-bit)
     * @param inputBalance Encrypted balance (32-bit)
     * @param ageProof Proof for age encryption
     * @param scoreProof Proof for score encryption
     * @param balanceProof Proof for balance encryption
     */
    function createProfile(
        externalEuint8 inputAge,
        externalEuint16 inputScore,
        externalEuint32 inputBalance,
        bytes calldata ageProof,
        bytes calldata scoreProof,
        bytes calldata balanceProof
    ) external {
        require(!_profiles[msg.sender].initialized, "Profile already exists");

        // Convert all external encrypted inputs
        euint8 age = FHE.fromExternal(inputAge, ageProof);
        euint16 score = FHE.fromExternal(inputScore, scoreProof);
        euint32 balance = FHE.fromExternal(inputBalance, balanceProof);

        // Store all values
        _profiles[msg.sender] = EncryptedProfile({
            age: age,
            score: score,
            balance: balance,
            initialized: true
        });

        // Grant permissions for all values
        // Contract needs access
        FHE.allowThis(age);
        FHE.allowThis(score);
        FHE.allowThis(balance);

        // User needs access for decryption
        FHE.allow(age, msg.sender);
        FHE.allow(score, msg.sender);
        FHE.allow(balance, msg.sender);

        emit ProfileCreated(msg.sender);
    }

    /**
     * @notice Updates specific fields of the profile
     * @dev Shows how to update individual encrypted values
     */
    function updateScore(
        externalEuint16 inputScore,
        bytes calldata scoreProof
    ) external {
        require(_profiles[msg.sender].initialized, "Profile does not exist");

        euint16 newScore = FHE.fromExternal(inputScore, scoreProof);
        _profiles[msg.sender].score = newScore;

        FHE.allowThis(newScore);
        FHE.allow(newScore, msg.sender);

        emit ProfileUpdated(msg.sender);
    }

    /**
     * @notice Updates the balance by adding an encrypted amount
     * @dev Demonstrates homomorphic operation on one field
     */
    function addToBalance(
        externalEuint32 inputAmount,
        bytes calldata amountProof
    ) external {
        require(_profiles[msg.sender].initialized, "Profile does not exist");

        euint32 amount = FHE.fromExternal(inputAmount, amountProof);

        // Homomorphic addition on encrypted balance
        euint32 newBalance = FHE.add(_profiles[msg.sender].balance, amount);
        _profiles[msg.sender].balance = newBalance;

        FHE.allowThis(newBalance);
        FHE.allow(newBalance, msg.sender);

        emit ProfileUpdated(msg.sender);
    }

    /**
     * @notice Retrieves all encrypted values for the caller
     * @return age Encrypted age
     * @return score Encrypted score
     * @return balance Encrypted balance
     */
    function getProfile() external view returns (
        euint8 age,
        euint16 score,
        euint32 balance
    ) {
        require(_profiles[msg.sender].initialized, "Profile does not exist");

        EncryptedProfile memory profile = _profiles[msg.sender];
        return (profile.age, profile.score, profile.balance);
    }

    /**
     * @notice Gets only the encrypted balance
     * @dev Demonstrates retrieving individual encrypted fields
     */
    function getBalance() external view returns (euint32) {
        require(_profiles[msg.sender].initialized, "Profile does not exist");
        return _profiles[msg.sender].balance;
    }

    /**
     * @notice Grants access to all profile values to another address
     * @dev Shows batch permission granting
     */
    function grantFullAccess(address otherUser) external {
        require(_profiles[msg.sender].initialized, "Profile does not exist");

        EncryptedProfile memory profile = _profiles[msg.sender];

        FHE.allow(profile.age, otherUser);
        FHE.allow(profile.score, otherUser);
        FHE.allow(profile.balance, otherUser);
    }
}
