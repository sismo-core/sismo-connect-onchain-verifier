// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "src/libs/zk-connect/ZkConnectLib.sol";

contract ZkConnectTest is ZkConnect {

    constructor(
        bytes16 appId
    ) ZkConnect(appId) {}

    function buildClaimTest(bytes16 groupId) public pure returns (Claim memory) {
        return buildClaim(groupId);
    }

    function buildAuthTest(AuthType authType) public pure returns (Auth memory) {
        return buildAuth(authType);
    }

    function verifyClaimTest(bytes memory responseBytes, Claim memory claimRequest) public returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest});
    }

    function verifyClaimAndNamespace(bytes memory responseBytes, Claim memory claimRequest, bytes16 namespace) public returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest, namespace: namespace});
    }

    function verifyClaimAndMessageTest(bytes memory responseBytes, Claim memory claimRequest, bytes memory messageSignatureRequest) public returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
    }

    function verifyAuthAndMessageTest(bytes memory responseBytes, Auth memory authRequest, bytes memory messageSignatureRequest) public returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, authRequest: authRequest, messageSignatureRequest: messageSignatureRequest});
    }

    function verifyTest(bytes memory zkConnectResponse, ZkConnectRequest memory zkConnectRequest) public returns (ZkConnectVerifiedResult memory) {
        return verify(zkConnectResponse, zkConnectRequest);
    }



}