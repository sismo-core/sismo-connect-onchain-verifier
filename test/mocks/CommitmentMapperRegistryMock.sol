// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ICommitmentMapperRegistry} from "src/periphery/interfaces/ICommitmentMapperRegistry.sol";

contract CommitmentMapperRegistryMock is ICommitmentMapperRegistry {
    uint256[2] public edDSAPubKey;
    address private _commitmentMapperAddress;

    function initialize(address, uint256[2] memory, address) external {}

    function updateCommitmentMapperEdDSAPubKey(uint256[2] memory newEdDSAPubKey) external {
        edDSAPubKey = newEdDSAPubKey;
    }

    function updateCommitmentMapperAddress(address newAddress) external {
        _commitmentMapperAddress = newAddress;
    }

    function getEdDSAPubKey() external view returns (uint256[2] memory) {
        return edDSAPubKey;
    }

    function getAddress() external view override returns (address) {
        return _commitmentMapperAddress;
    }
}
