// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface ICommitmentMapperRegistry {
    event UpdatedCommitmentMapperEdDSAPubKey(uint256[2] newEdDSAPubKey);

    /**
     * @dev Updates the EdDSA public key
     * @param newEdDSAPubKey new EdDSA pubic key
     */
    function updateCommitmentMapperEdDSAPubKey(uint256[2] memory newEdDSAPubKey) external;

    /**
     * @dev Getter of the address of the commitment mapper
     */
    function getEdDSAPubKey() external view returns (uint256[2] memory);
}
