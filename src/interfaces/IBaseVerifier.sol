// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libs/Struct.sol";

interface IBaseVerifier {
    function verify(bytes16 appId, bytes16 namespace, ZkConnectProof memory proof)
        external
        returns (uint256 vaultId, VerifiedStatement memory);
}
