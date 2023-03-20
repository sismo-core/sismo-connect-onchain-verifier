// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ICommitmentMapperRegistry} from "./interfaces/ICommitmentMapperRegistry.sol";

/**
 * @title Commitment Mapper Registry Contract
 * @author Sismo
 * @notice This contract stores information about the commitment mapper.
 * Its ethereum address and its EdDSA public key
 * For more information: https://commitment-mapper.docs.sismo.io
 *
 *
 */
contract CommitmentMapperRegistry is ICommitmentMapperRegistry, Ownable {
    uint8 public constant IMPLEMENTATION_VERSION = 2;

    uint256[2] internal _commitmentMapperPubKey;

    /**
     * @dev Constructor
     * @param owner Owner of the contract, can update public key and address
     * @param commitmentMapperEdDSAPubKey EdDSA public key of the commitment mapper
     */
    constructor(address owner, uint256[2] memory commitmentMapperEdDSAPubKey) {
        _transferOwnership(owner);
        _updateCommitmentMapperEdDSAPubKey(commitmentMapperEdDSAPubKey);
    }

    /**
     * @dev Updates the EdDSA public key
     * @param newEdDSAPubKey new EdDSA pubic key
     */
    function updateCommitmentMapperEdDSAPubKey(uint256[2] memory newEdDSAPubKey) external onlyOwner {
        _updateCommitmentMapperEdDSAPubKey(newEdDSAPubKey);
    }

    /**
     * @dev Getter of the EdDSA public key of the commitment mapper
     */
    function getEdDSAPubKey() external view override returns (uint256[2] memory) {
        return _commitmentMapperPubKey;
    }

    function _updateCommitmentMapperEdDSAPubKey(uint256[2] memory pubKey) internal {
        _commitmentMapperPubKey = pubKey;
        emit UpdatedCommitmentMapperEdDSAPubKey(pubKey);
    }
}
