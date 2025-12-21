// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title FHECounter
 * @notice A simple FHE counter contract demonstrating basic encrypted operations
 * @dev This example shows how to:
 *   - Store encrypted values on-chain
 *   - Perform homomorphic operations (addition, subtraction)
 *   - Manage access control for encrypted data
 *   - Handle encrypted inputs with proofs
 */
contract FHECounter is ZamaEthereumConfig {
    euint32 private _count;

    event CounterIncremented(address indexed user);
    event CounterDecremented(address indexed user);

    /**
     * @notice Returns the encrypted count
     * @dev The count remains encrypted and can only be decrypted by authorized parties
     * @return The encrypted counter value
     */
    function getCount() external view returns (euint32) {
        return _count;
    }

    /**
     * @notice Increments the counter by an encrypted value
     * @dev This example demonstrates:
     *   - Accepting encrypted input with proof
     *   - Performing homomorphic addition
     *   - Granting proper permissions
     * @param inputEuint32 The encrypted value to add
     * @param inputProof Zero-knowledge proof for the encrypted input
     */
    function increment(externalEuint32 inputEuint32, bytes calldata inputProof) external {
        // Convert external encrypted input to internal encrypted type
        euint32 encryptedValue = FHE.fromExternal(inputEuint32, inputProof);

        // Perform homomorphic addition on encrypted values
        _count = FHE.add(_count, encryptedValue);

        // Grant permissions: contract needs access for future operations
        FHE.allowThis(_count);

        // Grant permissions: user needs access to decrypt
        FHE.allow(_count, msg.sender);

        emit CounterIncremented(msg.sender);
    }

    /**
     * @notice Decrements the counter by an encrypted value
     * @dev This example demonstrates:
     *   - Homomorphic subtraction
     *   - No overflow/underflow checks (for simplicity)
     * @param inputEuint32 The encrypted value to subtract
     * @param inputProof Zero-knowledge proof for the encrypted input
     */
    function decrement(externalEuint32 inputEuint32, bytes calldata inputProof) external {
        euint32 encryptedValue = FHE.fromExternal(inputEuint32, inputProof);

        // Perform homomorphic subtraction on encrypted values
        _count = FHE.sub(_count, encryptedValue);

        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);

        emit CounterDecremented(msg.sender);
    }

    /**
     * @notice Resets the counter to an encrypted value
     * @dev Useful for demonstrating direct encrypted value assignment
     * @param inputEuint32 The new encrypted value
     * @param inputProof Zero-knowledge proof for the encrypted input
     */
    function reset(externalEuint32 inputEuint32, bytes calldata inputProof) external {
        _count = FHE.fromExternal(inputEuint32, inputProof);

        FHE.allowThis(_count);
        FHE.allow(_count, msg.sender);
    }
}
