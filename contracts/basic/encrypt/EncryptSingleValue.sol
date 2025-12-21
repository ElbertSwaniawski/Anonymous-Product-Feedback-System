// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title EncryptSingleValue
 * @notice Demonstrates the FHE encryption mechanism and common pitfalls
 * @dev This example shows:
 *   - How to accept encrypted inputs
 *   - Why input proofs are required
 *   - Proper permission management
 *   - Common mistakes to avoid
 */
contract EncryptSingleValue is ZamaEthereumConfig {
    // Storage for encrypted values per user
    mapping(address => euint32) private _userValues;

    event ValueStored(address indexed user);

    /**
     * @notice Stores an encrypted value for the caller
     * @dev CORRECT PATTERN:
     *   1. Accept externalEuint32 + inputProof
     *   2. Convert using FHE.fromExternal()
     *   3. Grant both contract and user permissions
     *
     * @param inputValue The encrypted value from the user
     * @param inputProof Zero-knowledge proof that the encryption is valid
     */
    function storeValue(
        externalEuint32 inputValue,
        bytes calldata inputProof
    ) external {
        // ✅ CORRECT: Convert external encrypted input with proof validation
        euint32 encryptedValue = FHE.fromExternal(inputValue, inputProof);

        // Store the encrypted value
        _userValues[msg.sender] = encryptedValue;

        // ✅ CORRECT: Grant contract permission for future operations
        FHE.allowThis(encryptedValue);

        // ✅ CORRECT: Grant user permission for decryption
        FHE.allow(encryptedValue, msg.sender);

        emit ValueStored(msg.sender);
    }

    /**
     * @notice Retrieves the caller's stored encrypted value
     * @dev The value remains encrypted when retrieved
     * @return The encrypted value
     */
    function getValue() external view returns (euint32) {
        return _userValues[msg.sender];
    }

    /**
     * @notice Example of INCORRECT pattern - Missing allowThis
     * @dev ❌ ANTI-PATTERN: This will fail in production because
     *      the contract won't have permission to use the value later
     */
    function incorrectStoreWithoutAllowThis(
        externalEuint32 inputValue,
        bytes calldata inputProof
    ) external {
        euint32 encryptedValue = FHE.fromExternal(inputValue, inputProof);
        _userValues[msg.sender] = encryptedValue;

        // ❌ WRONG: Missing FHE.allowThis() - contract can't use this value later
        FHE.allow(encryptedValue, msg.sender);
    }

    /**
     * @notice Example of INCORRECT pattern - Missing proof validation
     * @dev ❌ ANTI-PATTERN: This won't compile/work because you can't
     *      directly assign external encrypted values
     */
    // function incorrectDirectAssignment(externalEuint32 inputValue) external {
    //     // ❌ WRONG: Can't directly assign external encrypted value
    //     // _userValues[msg.sender] = inputValue; // This won't compile
    // }

    /**
     * @notice Allows another address to access the caller's value
     * @dev Demonstrates how to grant additional permissions
     * @param otherUser The address to grant access to
     */
    function grantAccess(address otherUser) external {
        euint32 value = _userValues[msg.sender];

        // Grant permission to another user
        FHE.allow(value, otherUser);
    }
}
