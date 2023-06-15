// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "src/libs/sismo-connect/SismoConnectLib.sol";

// This contract is used to expose internal functions of SismoConnect for testing purposes
// It is NOT deployed in production
// see: https://book.getfoundry.sh/tutorials/best-practices?highlight=coverage#test-harnesses
contract SismoConnectHarness is SismoConnect {
  constructor(
    bytes16 appId,
    bool isImpersonationMode
  ) SismoConnect(buildConfig(appId, isImpersonationMode)) {}

  function exposed_buildClaim(bytes16 groupId) external view returns (ClaimRequest memory) {
    return buildClaim(groupId);
  }

  function exposed_buildAuth(AuthType authType) external view returns (AuthRequest memory) {
    return buildAuth(authType);
  }

  function exposed_buildAuth(
    AuthType authType,
    bool isAnon
  ) external view returns (AuthRequest memory) {
    return buildAuth({authType: authType, isAnon: isAnon});
  }

  function exposed_buildAuth(
    AuthType authType,
    bool isOptional,
    bool isSelectableByUser
  ) external view returns (AuthRequest memory) {
    return
      buildAuth({
        authType: authType,
        isOptional: isOptional,
        isSelectableByUser: isSelectableByUser
      });
  }

  function exposed_buildAuth(
    AuthType authType,
    uint256 userId
  ) external view returns (AuthRequest memory) {
    return buildAuth({authType: authType, userId: userId});
  }

  function exposed_buildAuth(
    AuthType authType,
    bool isSelectableByUser,
    bool isOptional,
    uint256 userId
  ) external view returns (AuthRequest memory) {
    return
      buildAuth({
        authType: authType,
        isSelectableByUser: isSelectableByUser,
        isOptional: isOptional,
        userId: userId
      });
  }

  function exposed_buildSignature(
    bytes memory message
  ) external view returns (SignatureRequest memory) {
    return buildSignature(message);
  }

  function exposed_verify(
    bytes memory responseBytes,
    ClaimRequest memory claim
  ) external returns (SismoConnectVerifiedResult memory) {
    return verify({responseBytes: responseBytes, claim: claim});
  }

  function exposed_verify(
    bytes memory responseBytes,
    ClaimRequest memory claim,
    bytes16 namespace
  ) external returns (SismoConnectVerifiedResult memory) {
    return verify({responseBytes: responseBytes, claim: claim, namespace: namespace});
  }

  function exposed_verify(
    bytes memory responseBytes,
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) external returns (SismoConnectVerifiedResult memory) {
    return verify({responseBytes: responseBytes, claim: claim, signature: signature});
  }

  function exposed_verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    SignatureRequest memory signature
  ) external returns (SismoConnectVerifiedResult memory) {
    return verify({responseBytes: responseBytes, auth: auth, signature: signature});
  }

  function exposed_verify(
    bytes memory responseBytes,
    SismoConnectRequest memory request
  ) external returns (SismoConnectVerifiedResult memory) {
    return verify({responseBytes: responseBytes, request: request});
  }
}
