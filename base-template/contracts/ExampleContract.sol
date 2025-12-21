// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title ExampleContract
 * @notice This is a template contract demonstrating FHEVM basics
 * @dev Replace this contract with your FHEVM implementation
 */
contract ExampleContract is ZamaEthereumConfig {
    euint32 private _value;

    event ValueSet(address indexed setter);

    /**
     * @notice Sets an encrypted value
     * @param inputEuint32 The encrypted input value
     * @param inputProof The zero-knowledge proof for the input
     */
    function setValue(externalEuint32 inputEuint32, bytes calldata inputProof) external {
        euint32 encryptedValue = FHE.fromExternal(inputEuint32, inputProof);
        _value = encryptedValue;

        FHE.allowThis(_value);
        FHE.allow(_value, msg.sender);

        emit ValueSet(msg.sender);
    }

    /**
     * @notice Gets the encrypted value
     * @return The encrypted value
     */
    function getValue() external view returns (euint32) {
        return _value;
    }
}
