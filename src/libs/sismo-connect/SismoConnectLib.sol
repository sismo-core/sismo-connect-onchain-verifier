// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";
import {RequestBuilder} from "src/libs/utils/RequestBuilder.sol";
import {AuthRequestBuilder} from "src/libs/utils/AuthRequestBuilder.sol";
import {ClaimRequestBuilder} from "src/libs/utils/ClaimRequestBuilder.sol";
import {SignatureBuilder} from "src/libs/utils/SignatureBuilder.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ISismoConnectVerifier} from "src/interfaces/ISismoConnectVerifier.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";
import {SismoConnectHelper} from "src/libs/utils/SismoConnectHelper.sol";
import {IHydraS2Verifier} from "src/verifiers/IHydraS2Verifier.sol";
import {AuthMatchingLib} from "src/libs/sismo-connect/AuthMatchingLib.sol";
import {ClaimMatchingLib} from "src/libs/sismo-connect/ClaimMatchingLib.sol";

contract SismoConnect is Context {
  uint256 public constant SISMO_CONNECT_LIB_VERSION = 2;

  IAddressesProvider public constant ADDRESSES_PROVIDER =
    IAddressesProvider(0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05);

  ISismoConnectVerifier internal _sismoConnectVerifier;
  bytes16 public appId;

  constructor(bytes16 appIdentifier) {
    appId = appIdentifier;
    _sismoConnectVerifier = ISismoConnectVerifier(
      ADDRESSES_PROVIDER.get(string("sismoConnectVerifier-v1"))
    );
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, claim, signature, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, claim, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, signature, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claim, signature, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claim,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claim, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, claim, signature);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    ClaimRequest memory claim
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, claim);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth,
    SignatureRequest memory signature
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth, signature);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claim, signature);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory auth
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auth);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claim
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claim);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    SismoConnectRequest memory request
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, claims, signature, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, claims, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, signature, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claims, signature, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest[] memory claims,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claims, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, claims, signature);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, claims);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths,
    SignatureRequest memory signature
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths, signature);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claims, signature);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest[] memory auths
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(auths);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest[] memory claims
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claims);
    return _sismoConnectVerifier.verify(response, request);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, value, claimType, extraData);
  }

  function buildClaim(bytes16 groupId) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp);
  }

  function buildClaim(bytes16 groupId, uint256 value) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, value);
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, value);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, groupTimestamp, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return ClaimRequestBuilder.build(groupId, value, claimType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, isAnon, userId, extraData);
  }

  function buildAuth(AuthType authType) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType);
  }

  function buildAuth(AuthType authType, bool isAnon) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, isAnon);
  }

  function buildAuth(AuthType authType, uint256 userId) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, userId);
  }

  function buildAuth(
    AuthType authType,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, isAnon, userId);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, isAnon, extraData);
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return AuthRequestBuilder.build(authType, userId, extraData);
  }

  function buildSignature(bytes memory message) internal pure returns (SignatureRequest memory) {
    return SignatureBuilder.build(message);
  }

  function buildSignature(
    bytes memory message,
    bool isSelectableByUser
  ) internal pure returns (SignatureRequest memory) {
    return SignatureBuilder.build(message, isSelectableByUser);
  }

  function buildSignature(
    bytes memory message,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory) {
    return SignatureBuilder.build(message, extraData);
  }

  function buildSignature(
    bytes memory message,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory) {
    return SignatureBuilder.build(message, isSelectableByUser, extraData);
  }

  function buildSignature(bool isSelectableByUser) external pure returns (SignatureRequest memory) {
    return SignatureBuilder.build(isSelectableByUser);
  }

  function buildSignature(
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory) {
    return SignatureBuilder.build(isSelectableByUser, extraData);
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, claim, signature, appId);
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, claim, appId);
  }

  function buildRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claim, signature, appId);
  }

  function buildRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, signature, appId);
  }

  function buildRequest(
    ClaimRequest memory claim
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claim, appId);
  }

  function buildRequest(
    AuthRequest memory auth
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, appId);
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, claim, signature, appId, namespace);
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, claim, appId, namespace);
  }

  function buildRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claim, signature, appId, namespace);
  }

  function buildRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, signature, appId, namespace);
  }

  function buildRequest(
    ClaimRequest memory claim,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claim, appId, namespace);
  }

  function buildRequest(
    AuthRequest memory auth,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auth, appId, namespace);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, claims, signature, appId);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, claims, appId);
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claims, signature, appId);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    SignatureRequest memory signature
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, signature, appId);
  }

  function buildRequest(
    ClaimRequest[] memory claims
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claims, appId);
  }

  function buildRequest(
    AuthRequest[] memory auths
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, appId);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, claims, signature, appId, namespace);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, claims, appId, namespace);
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claims, signature, appId, namespace);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, signature, appId, namespace);
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claims, appId, namespace);
  }

  function buildRequest(
    AuthRequest[] memory auths,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(auths, appId, namespace);
  }
}
