// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/libs/utils/Structs.sol";
import {RequestBuilder} from "src/libs/utils/RequestBuilder.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ISismoConnectLib} from "./ISismoConnectLib.sol";
import {ISismoConnectVerifier} from "src/interfaces/ISismoConnectVerifier.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract SismoConnect is ISismoConnectLib, Context {
  uint256 public constant SISMO_CONNECT_LIB_VERSION = 2;

  IAddressesProvider public constant ADDRESSES_PROVIDER =
    IAddressesProvider(0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05);

  ISismoConnectVerifier internal _sismoConnectVerifier;
  bytes16 public appId;

  constructor(bytes16 appIdentifier) {
    appId = appIdentifier;
    _sismoConnectVerifier = ISismoConnectVerifier(ADDRESSES_PROVIDER.get(string("sismoConnectVerifier-v1")));
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    Claim memory claimRequest,
    bytes memory signatureRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(
      claimRequest,
      authRequest,
      signatureRequest,
      namespace
    );
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    Claim memory claimRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, authRequest, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(
      authRequest,
      signatureRequest,
      namespace
    );
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Claim memory claimRequest,
    bytes memory signatureRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(
      claimRequest,
      signatureRequest,
      namespace
    );
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(authRequest, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Claim memory claimRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    Claim memory claimRequest,
    bytes memory signatureRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(
      claimRequest,
      authRequest,
      signatureRequest
    );
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    Claim memory claimRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, authRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest,
    bytes memory signatureRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(authRequest, signatureRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Claim memory claimRequest,
    bytes memory signatureRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, signatureRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Auth memory authRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(authRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    Claim memory claimRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    SismoConnectRequest memory request
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    return _sismoConnectVerifier.verify(response, request);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, claimType, extraData);
  }

  function buildClaim(bytes16 groupId) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId);
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp);
  }

  function buildClaim(bytes16 groupId, uint256 value) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value);
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, claimType);
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value, claimType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bytes memory extraData
  ) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, isAnon, userId, extraData);
  }

  function buildAuth(AuthType authType) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType);
  }

  function buildAuth(AuthType authType, bool isAnon) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, isAnon);
  }

  function buildAuth(AuthType authType, uint256 userId) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, userId);
  }

  function buildAuth(AuthType authType, bytes memory extraData) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, isAnon, userId);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, isAnon, extraData);
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) internal pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, userId, extraData);
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory signatureRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, signatureRequest, appId);
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, appId);
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes memory signatureRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, signatureRequest, appId);
  }

  function buildRequest(
    Auth memory authRequest,
    bytes memory signatureRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, signatureRequest, appId);
  }

  function buildRequest(Claim memory claimRequest) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, appId);
  }

  function buildRequest(Auth memory authRequest) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, appId);
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return
      RequestBuilder.buildRequest(
        claimRequest,
        authRequest,
        signatureRequest,
        appId,
        namespace
      );
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, appId, namespace);
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes memory signatureRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, signatureRequest, appId, namespace);
  }

  function buildRequest(
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, signatureRequest, appId, namespace);
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, appId, namespace);
  }

  function buildRequest(
    Auth memory authRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, appId, namespace);
  }
}
