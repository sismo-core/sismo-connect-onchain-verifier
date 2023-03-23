// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libs/utils/Struct.sol";

interface IBaseVerifier {
    function verifyClaim(bytes16 appId, bytes16 namespace, ZkConnectProof memory proof)
        external
        returns (VerifiedClaim memory);

    function verifyAuthProof(bytes16 appId, ZkConnectProof memory proof) external returns (VerifiedAuth memory);
}
