// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title PublicDecryptSingleValue
 * @notice Demonstrates public decryption of encrypted values
 * @dev This example shows:
 *   - How to reveal encrypted values publicly
 *   - When public decryption is appropriate
 *   - Selective transparency patterns
 *   - Combining private and public operations
 */
contract PublicDecryptSingleValue is ZamaEthereumConfig {
    // Private encrypted values
    mapping(address => euint32) private _secrets;

    // Public revealed values
    mapping(address => uint32) private _revealed;

    event SecretStored(address indexed user);
    event ValueRevealed(address indexed user, uint32 value);

    /**
     * @notice Stores an encrypted secret
     * @param inputSecret The encrypted secret value
     * @param inputProof Zero-knowledge proof
     */
    function storeSecret(
        externalEuint32 inputSecret,
        bytes calldata inputProof
    ) external {
        euint32 encrypted = FHE.fromExternal(inputSecret, inputProof);

        _secrets[msg.sender] = encrypted;

        FHE.allowThis(encrypted);
        FHE.allow(encrypted, msg.sender);

        emit SecretStored(msg.sender);
    }

    /**
     * @notice Gets the encrypted secret (private)
     * @dev Returns value that can be decrypted by authorized parties
     */
    function getEncryptedSecret() external view returns (euint32) {
        return _secrets[msg.sender];
    }

    /**
     * @notice Reveals the secret publicly
     * @dev This is an example of SELECTIVE TRANSPARENCY:
     *      - Value is encrypted initially
     *      - Owner can reveal it when appropriate
     *      - Once revealed, it becomes public
     */
    function revealSecret() external {
        require(_secrets[msg.sender] != euint32.wrap(0), "No secret stored");

        // In a real implementation, decryption would happen here
        // For this example, we show the pattern
        euint32 encrypted = _secrets[msg.sender];

        // Decrypt would happen off-chain via relayer in real implementation
        // For demo purposes, this shows where decryption would occur

        // Once decrypted, the public value is revealed
        _revealed[msg.sender] = 42; // Placeholder for decrypted value

        emit ValueRevealed(msg.sender, _revealed[msg.sender]);
    }

    /**
     * @notice Gets the publicly revealed value
     * @dev Anyone can see this value - it's public
     */
    function getRevealedValue(address user) external view returns (uint32) {
        return _revealed[user];
    }

    /**
     * @notice Shows commitment pattern - encrypt then later reveal
     * @dev Useful for:
     *   - Sealed bids (encrypt -> reveal later)
     *   - Timed disclosures
     *   - Selective transparency
     */
    function isValueRevealed(address user) external view returns (bool) {
        return _revealed[user] != 0;
    }

    /**
     * @notice Demonstrates threshold revelation
     * @dev Example: Reveal only if certain conditions met
     */
    function revealIfConditionMet(bool condition) external {
        require(_secrets[msg.sender] != euint32.wrap(0), "No secret stored");
        require(condition, "Condition not met");

        // Reveal the secret
        _revealed[msg.sender] = 42; // Placeholder

        emit ValueRevealed(msg.sender, _revealed[msg.sender]);
    }

    /**
     * @notice Returns both encrypted and revealed values
     * @dev Shows how private and public values coexist
     * @return encrypted The encrypted secret (decryptable by authorized parties)
     * @return revealed The publicly revealed value (readable by anyone)
     */
    function getBothValues() external view returns (euint32 encrypted, uint32 revealed) {
        encrypted = _secrets[msg.sender];
        revealed = _revealed[msg.sender];
    }

    /**
     * @notice Demonstrates ANTI-PATTERN: Public visibility of encrypted data
     * @dev ❌ WRONG: Returning encrypted value from view function doesn't protect privacy
     *      because block data is eventually decryptable
     */
    function antiPatternPublicEncrypted() external view returns (euint32) {
        // ❌ This appears to be private but encrypted data is still on-chain
        return _secrets[msg.sender];
    }

    /**
     * @notice Clears both encrypted and revealed values
     * @dev Shows cleanup of sensitive data
     */
    function clearValues() external {
        _secrets[msg.sender] = euint32.wrap(0);
        _revealed[msg.sender] = 0;
    }
}
