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
    AuthRequest memory authRequest,
    ClaimRequest memory claimRequest,
    SignatureRequest memory signatureRequest,
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
    AuthRequest memory authRequest,
    ClaimRequest memory claimRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, authRequest, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory authRequest,
    SignatureRequest memory signatureRequest,
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
    ClaimRequest memory claimRequest,
    SignatureRequest memory signatureRequest,
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
    AuthRequest memory authRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(authRequest, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claimRequest,
    bytes16 namespace
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, namespace);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory authRequest,
    ClaimRequest memory claimRequest,
    SignatureRequest memory signatureRequest
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
    AuthRequest memory authRequest,
    ClaimRequest memory claimRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, authRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory authRequest,
    SignatureRequest memory signatureRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(authRequest, signatureRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claimRequest,
    SignatureRequest memory signatureRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(claimRequest, signatureRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    AuthRequest memory authRequest
  ) internal returns (SismoConnectVerifiedResult memory) {
    SismoConnectResponse memory response = abi.decode(responseBytes, (SismoConnectResponse));
    SismoConnectRequest memory request = buildRequest(authRequest);
    return _sismoConnectVerifier.verify(response, request);
  }

  function verify(
    bytes memory responseBytes,
    ClaimRequest memory claimRequest
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
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, claimType, extraData);
  }

  function buildClaim(bytes16 groupId) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId);
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp);
  }

  function buildClaim(bytes16 groupId, uint256 value) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, value);
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, claimType);
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) internal pure returns (ClaimRequest memory) {
    return RequestBuilder.buildClaim(groupId, value, claimType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, isAnon, userId, extraData);
  }

  function buildAuth(AuthType authType) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType);
  }

  function buildAuth(AuthType authType, bool isAnon) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, isAnon);
  }

  function buildAuth(AuthType authType, uint256 userId) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, userId);
  }

  function buildAuth(AuthType authType, bytes memory extraData) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, isAnon, userId);
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, isAnon, extraData);
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) internal pure returns (AuthRequest memory) {
    return RequestBuilder.buildAuth(authType, userId, extraData);
  }

  function buildSignature(bytes memory message) internal pure returns (SignatureRequest memory) {
    return RequestBuilder.buildSignature(message);
  }

  function buildSignature(bytes memory message, bool isSelectableByUser) internal pure returns (SignatureRequest memory) {
    return RequestBuilder.buildSignature(message, isSelectableByUser);
  }

  function buildSignature(bytes memory message, bytes memory extraData) external pure returns (SignatureRequest memory) {
    return RequestBuilder.buildSignature(message, extraData);
  }

  function buildSignature(
    bytes memory message,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (SignatureRequest memory) {
    return RequestBuilder.buildSignature(message, isSelectableByUser, extraData);
  }

  function buildSignature(bool isSelectableByUser) external pure returns (SignatureRequest memory) {
    return RequestBuilder.buildSignature(isSelectableByUser);
  }

  function buildSignature(bool isSelectableByUser, bytes memory extraData) external pure returns (SignatureRequest memory) {
    return RequestBuilder.buildSignature(isSelectableByUser, extraData);
  }

  function buildRequest(
    ClaimRequest memory claimRequest,
    AuthRequest memory authRequest,
    SignatureRequest memory signatureRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, signatureRequest, appId);
  }

  function buildRequest(
    ClaimRequest memory claimRequest,
    AuthRequest memory authRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, appId);
  }

  function buildRequest(
    ClaimRequest memory claimRequest,
    SignatureRequest memory signatureRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, signatureRequest, appId);
  }

  function buildRequest(
    AuthRequest memory authRequest,
    SignatureRequest memory signatureRequest
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, signatureRequest, appId);
  }

  function buildRequest(ClaimRequest memory claimRequest) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, appId);
  }

  function buildRequest(AuthRequest memory authRequest) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, appId);
  }

  function buildRequest(
    ClaimRequest memory claimRequest,
    AuthRequest memory authRequest,
    SignatureRequest memory signatureRequest,
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
    ClaimRequest memory claimRequest,
    AuthRequest memory authRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, appId, namespace);
  }

  function buildRequest(
    ClaimRequest memory claimRequest,
    SignatureRequest memory signatureRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, signatureRequest, appId, namespace);
  }

  function buildRequest(
    AuthRequest memory authRequest,
    SignatureRequest memory signatureRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, signatureRequest, appId, namespace);
  }

  function buildRequest(
    ClaimRequest memory claimRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, appId, namespace);
  }

  function buildRequest(
    AuthRequest memory authRequest,
    bytes16 namespace
  ) internal view returns (SismoConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, appId, namespace);
  }
}
