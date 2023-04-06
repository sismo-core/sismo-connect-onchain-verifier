// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "src/libs/zk-connect/SismoConnectLib.sol";

// This contract is used to expose internal functions of SismoConnect for testing purposes
// It is NOT deployed in production
// see: https://book.getfoundry.sh/tutorials/best-practices?highlight=coverage#test-harnesses
contract SismoConnectHarness is SismoConnect {

    constructor(
        bytes16 appId
    ) SismoConnect(appId) {}

    function exposed_buildClaim(bytes16 groupId) external pure returns (ClaimRequest memory) {
        return buildClaim(groupId);
    }

    function exposed_buildAuth(AuthType authType) external pure returns (AuthRequest memory) {
        return buildAuth(authType);
    }

    function exposed_buildSignature(bytes memory message) external pure returns (SignatureRequest memory) {
        return buildSignature(message);
    }

    function exposed_verify(bytes memory responseBytes, ClaimRequest memory claimRequest) external returns (SismoConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest});
    }

    function exposed_verify(bytes memory responseBytes, ClaimRequest memory claimRequest, bytes16 namespace) external returns (SismoConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest, namespace: namespace});
    }

    function exposed_verify(bytes memory responseBytes, ClaimRequest memory claimRequest, SignatureRequest memory signatureRequest) external returns (SismoConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, claimRequest: claimRequest, signatureRequest: signatureRequest});
    }

    function exposed_verify(bytes memory responseBytes, AuthRequest memory authRequest, SignatureRequest memory signatureRequest) external returns (SismoConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, authRequest: authRequest, signatureRequest: signatureRequest});
    }

    function exposed_verify(bytes memory responseBytes, SismoConnectRequest memory request) external returns (SismoConnectVerifiedResult memory) {
        return verify({responseBytes: responseBytes, request: request});
    }
}