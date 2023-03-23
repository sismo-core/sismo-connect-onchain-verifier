// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "../libs/utils/Struct.sol";

interface IBaseVerifier {
    function verify(
        bytes16 appId,
        bytes16 namespace,
        ZkConnectProof memory proof,
        bytes memory signedMessage
    ) external returns (uint256 vaultId, VerifiedStatement memory);

    function verifyAuthProof(bytes16 appId, AuthProof memory authProof, bytes memory signedMessage) external returns (uint256);
}
