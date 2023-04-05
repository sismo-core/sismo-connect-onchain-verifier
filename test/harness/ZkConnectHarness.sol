// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "src/libs/zk-connect/ZkConnectLib.sol";

// This contract is used to expose internal functions of ZkConnect for testing purposes
// It is NOT deployed in production
// see: https://book.getfoundry.sh/tutorials/best-practices?highlight=coverage#test-harnesses
contract ZkConnectHarness is ZkConnect {

    constructor(
        bytes16 appId
    ) ZkConnect(appId) {}

    function exposed_buildClaim(bytes16 groupId) external pure returns (Claim memory) {
        return buildClaim(groupId);
    }

    function exposed_buildAuth(AuthType authType) external pure returns (Auth memory) {
        return buildAuth(authType);
    }

    function exposed_verify(bytes memory responseBytes, Claim memory claimRequest) external returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest});
    }

    function exposed_verify(bytes memory responseBytes, Claim memory claimRequest, bytes16 namespace) external returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest, namespace: namespace});
    }

    function exposed_verify(bytes memory responseBytes, Claim memory claimRequest, bytes memory messageSignatureRequest) external returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
    }

    function exposed_verify(bytes memory responseBytes, Auth memory authRequest, bytes memory messageSignatureRequest) external returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, authRequest: authRequest, messageSignatureRequest: messageSignatureRequest});
    }

    function exposed_verify(bytes memory responseBytes, ZkConnectRequest memory zkConnectRequest) external returns (ZkConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, zkConnectRequest: zkConnectRequest});
    }
}