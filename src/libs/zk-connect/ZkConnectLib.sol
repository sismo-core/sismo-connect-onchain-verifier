// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/libs/utils/Structs.sol";
import {RequestBuilder} from "src/libs/utils/RequestBuilder.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IZkConnectLib} from "./IZkConnectLib.sol";
import {IZkConnectVerifier} from "src/interfaces/IZkConnectVerifier.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract ZkConnect is IZkConnectLib, Context {
  uint256 public constant ZK_CONNECT_LIB_VERSION = 2;

  IAddressesProvider public constant ADDRESSES_PROVIDER =
    IAddressesProvider(0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05);

  IZkConnectVerifier internal _zkConnectVerifier;
  bytes16 public appId;

  constructor(bytes16 appIdentifier) {
    appId = appIdentifier;
    _zkConnectVerifier = IZkConnectVerifier(ADDRESSES_PROVIDER.get(string("zkConnectVerifier-v2")));
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    Claim memory claimRequest,
    bytes memory messageSignatureRequest,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      claimRequest,
      authRequest,
      messageSignatureRequest,
      namespace
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    Claim memory claimRequest,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      claimRequest,
      authRequest,
      namespace
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    bytes memory messageSignatureRequest,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      authRequest,
      messageSignatureRequest,
      namespace
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Claim memory claimRequest,
    bytes memory messageSignatureRequest,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      claimRequest,
      messageSignatureRequest,
      namespace
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(authRequest, namespace);
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Claim memory claimRequest,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(claimRequest, namespace);
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    Claim memory claimRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      claimRequest,
      authRequest,
      messageSignatureRequest
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    Claim memory claimRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(claimRequest, authRequest);
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      authRequest,
      messageSignatureRequest
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Claim memory claimRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(
      claimRequest,
      messageSignatureRequest
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Auth memory authRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(authRequest);
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    Claim memory claimRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    ZkConnectRequest memory zkConnectRequest = buildZkConnectRequest(claimRequest);
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    ZkConnectRequest memory zkConnectRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequest);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, claimType, extraData);
  }

  function buildClaim(bytes16 groupId) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId);
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp);
  }

  function buildClaim(bytes16 groupId, uint256 value) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value);
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, claimType);
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, value, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, groupTimestamp, claimType, extraData);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return RequestBuilder.buildClaim(groupId, value, claimType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, anonMode, userId, extraData);
  }

  function buildAuth(AuthType authType) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType);
  }

  function buildAuth(AuthType authType, bool anonMode) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, anonMode);
  }

  function buildAuth(AuthType authType, uint256 userId) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, userId);
  }

  function buildAuth(AuthType authType, bytes memory extraData) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    uint256 userId
  ) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, anonMode, userId);
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, anonMode, extraData);
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return RequestBuilder.buildAuth(authType, userId, extraData);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, messageSignatureRequest, appId);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    Auth memory authRequest
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, appId);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, messageSignatureRequest, appId);
  }

  function buildZkConnectRequest(
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, messageSignatureRequest, appId);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, appId);
  }

  function buildZkConnectRequest(Auth memory authRequest) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, appId);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory messageSignatureRequest,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return
      RequestBuilder.buildRequest(
        claimRequest,
        authRequest,
        messageSignatureRequest,
        appId,
        namespace
      );
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, authRequest, appId, namespace);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    bytes memory messageSignatureRequest,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, messageSignatureRequest, appId, namespace);
  }

  function buildZkConnectRequest(
    Auth memory authRequest,
    bytes memory messageSignatureRequest,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, messageSignatureRequest, appId, namespace);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(claimRequest, appId, namespace);
  }

  function buildZkConnectRequest(
    Auth memory authRequest,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return RequestBuilder.buildRequest(authRequest, appId, namespace);
  }
}
