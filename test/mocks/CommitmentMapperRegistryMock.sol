// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ICommitmentMapperRegistry} from "src/periphery/interfaces/ICommitmentMapperRegistry.sol";

contract CommitmentMapperRegistryMock is ICommitmentMapperRegistry {
    uint256[2] public edDSAPubKey;

    function updateCommitmentMapperEdDSAPubKey(uint256[2] memory newEdDSAPubKey) external override {
        edDSAPubKey = newEdDSAPubKey;
    }

    function getEdDSAPubKey() external view override returns (uint256[2] memory) {
        return edDSAPubKey;
    }
}
