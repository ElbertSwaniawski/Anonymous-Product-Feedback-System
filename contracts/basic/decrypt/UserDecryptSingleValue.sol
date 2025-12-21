// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title UserDecryptSingleValue
 * @notice Demonstrates user decryption with permission requirements
 * @dev This example shows:
 *   - How users decrypt encrypted values
 *   - Why FHE.allow() is required for decryption
 *   - Common permission pitfalls
 *   - Access control for encrypted data
 */
contract UserDecryptSingleValue is ZamaEthereumConfig {
    // Store encrypted secrets for each user
    mapping(address => euint32) private _userSecrets;

    // Track which users have stored secrets
    mapping(address => bool) private _hasSecret;

    event SecretStored(address indexed user);
    event AccessGranted(address indexed owner, address indexed grantee);

    /**
     * @notice Stores an encrypted secret for the caller
     * @dev The secret can only be decrypted by addresses with permission
     * @param inputSecret The encrypted secret value
     * @param inputProof Zero-knowledge proof for the encrypted input
     */
    function storeSecret(
        externalEuint32 inputSecret,
        bytes calldata inputProof
    ) external {
        euint32 encryptedSecret = FHE.fromExternal(inputSecret, inputProof);

        _userSecrets[msg.sender] = encryptedSecret;
        _hasSecret[msg.sender] = true;

        // ✅ CORRECT: Grant contract permission
        FHE.allowThis(encryptedSecret);

        // ✅ CORRECT: Grant user permission for decryption
        FHE.allow(encryptedSecret, msg.sender);

        emit SecretStored(msg.sender);
    }

    /**
     * @notice Retrieves the caller's encrypted secret
     * @dev Returns encrypted value that can be decrypted client-side
     *      ONLY if the caller has permission (via FHE.allow)
     * @return The encrypted secret (can be decrypted client-side if permitted)
     */
    function getMySecret() external view returns (euint32) {
        require(_hasSecret[msg.sender], "No secret stored");

        // Returns encrypted value
        // User can decrypt client-side because we called FHE.allow() in storeSecret()
        return _userSecrets[msg.sender];
    }

    /**
     * @notice Allows another address to decrypt the caller's secret
     * @dev Demonstrates permission delegation
     * @param grantee The address to grant decryption access
     */
    function grantDecryptAccess(address grantee) external {
        require(_hasSecret[msg.sender], "No secret stored");
        require(grantee != address(0), "Invalid grantee");

        // Grant permission to decrypt
        FHE.allow(_userSecrets[msg.sender], grantee);

        emit AccessGranted(msg.sender, grantee);
    }

    /**
     * @notice Retrieves another user's secret (if permission granted)
     * @dev Will only work if the owner called grantDecryptAccess() for msg.sender
     * @param owner The address whose secret to retrieve
     * @return The encrypted secret (decryptable only if permission granted)
     */
    function getSharedSecret(address owner) external view returns (euint32) {
        require(_hasSecret[owner], "No secret stored for this user");

        // This returns encrypted value
        // Caller can decrypt ONLY if owner called grantDecryptAccess()
        return _userSecrets[owner];
    }

    /**
     * @notice Updates the caller's secret to a new encrypted value
     * @dev Shows how permission management works with updates
     */
    function updateSecret(
        externalEuint32 inputSecret,
        bytes calldata inputProof
    ) external {
        require(_hasSecret[msg.sender], "No secret stored");

        euint32 newSecret = FHE.fromExternal(inputSecret, inputProof);

        _userSecrets[msg.sender] = newSecret;

        // Must grant permissions to the new encrypted value
        FHE.allowThis(newSecret);
        FHE.allow(newSecret, msg.sender);

        emit SecretStored(msg.sender);
    }

    /**
     * @notice Checks if a user has stored a secret
     * @dev Public information (not encrypted)
     */
    function hasSecret(address user) external view returns (bool) {
        return _hasSecret[user];
    }

    /**
     * @notice Example of INCORRECT pattern - No permission granted
     * @dev ❌ ANTI-PATTERN: User won't be able to decrypt the returned value
     */
    function incorrectStoreWithoutPermission(
        externalEuint32 inputSecret,
        bytes calldata inputProof
    ) external {
        euint32 encryptedSecret = FHE.fromExternal(inputSecret, inputProof);
        _userSecrets[msg.sender] = encryptedSecret;

        FHE.allowThis(encryptedSecret);

        // ❌ WRONG: Missing FHE.allow(encryptedSecret, msg.sender)
        // User won't be able to decrypt this value client-side!
    }
}
