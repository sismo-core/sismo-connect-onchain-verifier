// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libs/Struct.sol";

interface IBaseVerifier {
    function verify(bytes16 appId, bytes16 namespace, VerifiableStatement memory statement)
        external
        returns (uint256 vaultId, uint256 proofId);
}
