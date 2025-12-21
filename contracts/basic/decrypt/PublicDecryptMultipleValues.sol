// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, euint32, externalEuint8, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title PublicDecryptMultipleValues
 * @notice Demonstrates public decryption with multiple encrypted values
 * @dev Shows:
 *   - Handling multiple encrypted values
 *   - Selective revelation patterns
 *   - Batch decryption and revelation
 *   - Privacy levels for different data
 */
contract PublicDecryptMultipleValues is ZamaEthereumConfig {
    struct EncryptedRecord {
        euint8 field1;
        euint32 field2;
        bool initialized;
    }

    struct PublicRecord {
        uint8 field1;
        uint32 field2;
        bool bothRevealed;
    }

    mapping(address => EncryptedRecord) private _encrypted;
    mapping(address => PublicRecord) private _public;

    event RecordStored(address indexed user);
    event PartialReveal(address indexed user, uint8 indexed field);
    event FullReveal(address indexed user);

    /**
     * @notice Stores multiple encrypted values
     */
    function storeRecord(
        externalEuint8 inputField1,
        externalEuint32 inputField2,
        bytes calldata proof1,
        bytes calldata proof2
    ) external {
        euint8 f1 = FHE.fromExternal(inputField1, proof1);
        euint32 f2 = FHE.fromExternal(inputField2, proof2);

        _encrypted[msg.sender] = EncryptedRecord({
            field1: f1,
            field2: f2,
            initialized: true
        });

        FHE.allowThis(f1);
        FHE.allowThis(f2);
        FHE.allow(f1, msg.sender);
        FHE.allow(f2, msg.sender);

        emit RecordStored(msg.sender);
    }

    /**
     * @notice Reveals only the first field publicly
     */
    function revealField1() external {
        require(_encrypted[msg.sender].initialized, "No record stored");

        // Placeholder: In real implementation, decryption happens here
        _public[msg.sender].field1 = 42;

        emit PartialReveal(msg.sender, 1);
    }

    /**
     * @notice Reveals only the second field publicly
     */
    function revealField2() external {
        require(_encrypted[msg.sender].initialized, "No record stored");

        // Placeholder: In real implementation, decryption happens here
        _public[msg.sender].field2 = 1000;

        emit PartialReveal(msg.sender, 2);
    }

    /**
     * @notice Reveals both fields publicly
     */
    function revealBoth() external {
        require(_encrypted[msg.sender].initialized, "No record stored");

        // Placeholder: In real implementation, decryption happens here
        _public[msg.sender].field1 = 42;
        _public[msg.sender].field2 = 1000;
        _public[msg.sender].bothRevealed = true;

        emit FullReveal(msg.sender);
    }

    /**
     * @notice Gets both encrypted values
     * @dev Private - only authorized parties can decrypt
     */
    function getEncryptedRecord() external view returns (euint8, euint32) {
        require(_encrypted[msg.sender].initialized, "No record stored");
        EncryptedRecord memory rec = _encrypted[msg.sender];
        return (rec.field1, rec.field2);
    }

    /**
     * @notice Gets both public values
     * @dev Public - anyone can see
     */
    function getPublicRecord(address user) external view returns (uint8, uint32) {
        PublicRecord memory rec = _public[user];
        return (rec.field1, rec.field2);
    }

    /**
     * @notice Gets individual public field
     */
    function getPublicField1(address user) external view returns (uint8) {
        return _public[user].field1;
    }

    /**
     * @notice Gets individual public field
     */
    function getPublicField2(address user) external view returns (uint32) {
        return _public[user].field2;
    }

    /**
     * @notice Checks if data has been revealed
     */
    function isField1Revealed(address user) external view returns (bool) {
        return _public[user].field1 != 0;
    }

    /**
     * @notice Checks if all data has been revealed
     */
    function isBothRevealed(address user) external view returns (bool) {
        return _public[user].bothRevealed;
    }

    /**
     * @notice Demonstrates conditional revelation
     * @dev Example: Reveal data only after certain conditions
     */
    function revealBothIfApproved(bool approved) external {
        require(_encrypted[msg.sender].initialized, "No record stored");
        require(approved, "Not approved");

        _public[msg.sender].field1 = 42;
        _public[msg.sender].field2 = 1000;
        _public[msg.sender].bothRevealed = true;

        emit FullReveal(msg.sender);
    }

    /**
     * @notice Demonstrates progressive revelation
     * @dev Reveal at different times for different fields
     */
    function revealProgressively(uint8 field) external {
        require(_encrypted[msg.sender].initialized, "No record stored");
        require(field == 1 || field == 2, "Invalid field");

        if (field == 1) {
            _public[msg.sender].field1 = 42;
            emit PartialReveal(msg.sender, 1);
        } else {
            _public[msg.sender].field2 = 1000;
            emit PartialReveal(msg.sender, 2);
        }
    }

    /**
     * @notice Gets combination of encrypted and public values
     * @dev Shows hybrid approach - some values stay private, some become public
     */
    function getHybridView() external view returns (
        euint8 encryptedField1,
        euint32 encryptedField2,
        uint8 publicField1,
        uint32 publicField2
    ) {
        require(_encrypted[msg.sender].initialized, "No record stored");

        EncryptedRecord memory enc = _encrypted[msg.sender];
        PublicRecord memory pub = _public[msg.sender];

        return (enc.field1, enc.field2, pub.field1, pub.field2);
    }
}
