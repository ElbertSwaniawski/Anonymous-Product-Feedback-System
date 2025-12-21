// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint8, euint32, externalEuint8, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title UserDecryptMultipleValues
 * @notice Demonstrates decrypting multiple encrypted values for users
 * @dev Shows:
 *   - Handling multiple encrypted values
 *   - Batch permission management
 *   - Individual and batch decryption
 *   - Access control for multiple values
 */
contract UserDecryptMultipleValues is ZamaEthereumConfig {
    struct EncryptedData {
        euint8 data1;
        euint32 data2;
        bool initialized;
    }

    mapping(address => EncryptedData) private _userData;

    event DataStored(address indexed user);
    event MultipleAccessGranted(address indexed owner, address indexed grantee);

    /**
     * @notice Stores multiple encrypted values for the caller
     * @param inputData1 First encrypted value (8-bit)
     * @param inputData2 Second encrypted value (32-bit)
     * @param proof1 Proof for first value
     * @param proof2 Proof for second value
     */
    function storeMultipleValues(
        externalEuint8 inputData1,
        externalEuint32 inputData2,
        bytes calldata proof1,
        bytes calldata proof2
    ) external {
        euint8 data1 = FHE.fromExternal(inputData1, proof1);
        euint32 data2 = FHE.fromExternal(inputData2, proof2);

        _userData[msg.sender] = EncryptedData({
            data1: data1,
            data2: data2,
            initialized: true
        });

        // Grant permissions for both values
        FHE.allowThis(data1);
        FHE.allowThis(data2);

        FHE.allow(data1, msg.sender);
        FHE.allow(data2, msg.sender);

        emit DataStored(msg.sender);
    }

    /**
     * @notice Retrieves first encrypted value
     * @dev Can be decrypted by caller (who has permission)
     */
    function getData1() external view returns (euint8) {
        require(_userData[msg.sender].initialized, "No data stored");
        return _userData[msg.sender].data1;
    }

    /**
     * @notice Retrieves second encrypted value
     * @dev Can be decrypted by caller (who has permission)
     */
    function getData2() external view returns (euint32) {
        require(_userData[msg.sender].initialized, "No data stored");
        return _userData[msg.sender].data2;
    }

    /**
     * @notice Retrieves both encrypted values together
     * @dev Returns tuple of encrypted values
     */
    function getAllData() external view returns (euint8, euint32) {
        require(_userData[msg.sender].initialized, "No data stored");

        EncryptedData memory data = _userData[msg.sender];
        return (data.data1, data.data2);
    }

    /**
     * @notice Grants decryption access to another user for both values
     * @dev Shows batch permission granting
     */
    function grantFullAccess(address grantee) external {
        require(_userData[msg.sender].initialized, "No data stored");
        require(grantee != address(0), "Invalid grantee");

        EncryptedData memory data = _userData[msg.sender];

        // Grant access to both values
        FHE.allow(data.data1, grantee);
        FHE.allow(data.data2, grantee);

        emit MultipleAccessGranted(msg.sender, grantee);
    }

    /**
     * @notice Grants access to only the first value
     * @dev Demonstrates selective permission granting
     */
    function grantPartialAccess(address grantee) external {
        require(_userData[msg.sender].initialized, "No data stored");

        // Grant access to only data1
        FHE.allow(_userData[msg.sender].data1, grantee);
    }

    /**
     * @notice Retrieves multiple values from another user (if permitted)
     */
    function getSharedData(address owner) external view returns (euint8, euint32) {
        require(_userData[owner].initialized, "No data stored for this user");

        EncryptedData memory data = _userData[owner];
        return (data.data1, data.data2);
    }

    /**
     * @notice Updates only the first value
     * @param inputData1 New encrypted value
     * @param proof1 Proof for new value
     */
    function updateData1(
        externalEuint8 inputData1,
        bytes calldata proof1
    ) external {
        require(_userData[msg.sender].initialized, "No data stored");

        euint8 newData1 = FHE.fromExternal(inputData1, proof1);
        _userData[msg.sender].data1 = newData1;

        FHE.allowThis(newData1);
        FHE.allow(newData1, msg.sender);

        emit DataStored(msg.sender);
    }

    /**
     * @notice Updates only the second value
     * @param inputData2 New encrypted value
     * @param proof2 Proof for new value
     */
    function updateData2(
        externalEuint32 inputData2,
        bytes calldata proof2
    ) external {
        require(_userData[msg.sender].initialized, "No data stored");

        euint32 newData2 = FHE.fromExternal(inputData2, proof2);
        _userData[msg.sender].data2 = newData2;

        FHE.allowThis(newData2);
        FHE.allow(newData2, msg.sender);

        emit DataStored(msg.sender);
    }

    /**
     * @notice Updates both values atomically
     * @param inputData1 New first encrypted value
     * @param inputData2 New second encrypted value
     * @param proof1 Proof for first value
     * @param proof2 Proof for second value
     */
    function updateBoth(
        externalEuint8 inputData1,
        externalEuint32 inputData2,
        bytes calldata proof1,
        bytes calldata proof2
    ) external {
        require(_userData[msg.sender].initialized, "No data stored");

        euint8 newData1 = FHE.fromExternal(inputData1, proof1);
        euint32 newData2 = FHE.fromExternal(inputData2, proof2);

        _userData[msg.sender].data1 = newData1;
        _userData[msg.sender].data2 = newData2;

        FHE.allowThis(newData1);
        FHE.allowThis(newData2);

        FHE.allow(newData1, msg.sender);
        FHE.allow(newData2, msg.sender);

        emit DataStored(msg.sender);
    }
}
