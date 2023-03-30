// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/libs/utils/Structs.sol";
import "src/libs/utils/ZkConnectRequestContentLib.sol";
import {ClaimRequestLib} from "src/libs/utils/ClaimRequestLib.sol";
import {AuthRequestLib} from "src/libs/utils/AuthRequestLib.sol";
import {DataRequestLib} from "src/libs/utils/DataRequestLib.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ZkConnectRequestContentLib} from "src/libs/utils/ZkConnectRequestContentLib.sol";
import {IZkConnectLib} from "./IZkConnectLib.sol";
import {IZkConnectVerifier} from "src/interfaces/IZkConnectVerifier.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract ZkConnect is IZkConnectLib, Context {
  uint256 public constant ZK_CONNECT_LIB_VERSION = 2;

  IAddressesProvider public immutable ADDRESSES_PROVIDER =
    IAddressesProvider(0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05);

  IZkConnectVerifier private _zkConnectVerifier;
  bytes16 public appId;

  constructor(bytes16 appIdentifier) {
    appId = appIdentifier;
    _zkConnectVerifier = IZkConnectVerifier(ADDRESSES_PROVIDER.get(string("zkConnectVerifier-v2")));
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    ZkConnectRequestContent memory zkConnectRequestContent,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    if (zkConnectResponseEncoded.length == 0) {
      revert ZkConnectResponseIsEmpty();
    }
    ZkConnectResponse memory zkConnectResponse = abi.decode(
      zkConnectResponseEncoded,
      (ZkConnectResponse)
    );
    return verify(zkConnectResponse, zkConnectRequestContent, namespace);
  }

  function verify(
    bytes memory zkConnectResponseEncoded,
    ZkConnectRequestContent memory zkConnectRequestContent
  ) public returns (ZkConnectVerifiedResult memory) {
    return verify(zkConnectResponseEncoded, zkConnectRequestContent, bytes16(keccak256("main")));
  }

  function verify(
    bytes memory zkConnectResponseEncoded
  ) public returns (ZkConnectVerifiedResult memory) {
    ZkConnectRequestContent memory zkConnectRequestContent;
    return verify(zkConnectResponseEncoded, zkConnectRequestContent, bytes16(keccak256("main")));
  }

  function verify(
    ZkConnectResponse memory zkConnectResponse,
    ZkConnectRequestContent memory zkConnectRequestContent,
    bytes16 namespace
  ) public returns (ZkConnectVerifiedResult memory) {
    if (zkConnectResponse.appId != appId) {
      revert AppIdMismatch(zkConnectResponse.appId, appId);
    }

    if (zkConnectResponse.namespace != namespace) {
      revert NamespaceMismatch(zkConnectResponse.namespace, namespace);
    }
    return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequestContent);
  }

  function getZkConnectVersion() public view returns (bytes32) {
    return _zkConnectVerifier.ZK_CONNECT_VERSION();
  }

  ///////////////////////////
  // groupId + groupTimestamp + value + claimType + extraData
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, value, claimType, extraData);
  }

  ///////////////////////////
  // groupId
  ///////////////////////////

  function buildClaim(bytes16 groupId) internal pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId);
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp);
  }

  function buildClaim(bytes16 groupId, uint256 value) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, value);
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, claimType);
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, extraData);
  }

  ///////////////////////////
  // groupId + groupTimestamp
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, value);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, extraData);
  }

  ///////////////////////////
  // groupId + value
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, value, extraData);
  }

  ///////////////////////////
  // groupId + claimType
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, claimType, extraData);
  }

  ///////////////////////////
  // groupId + extraData (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + groupTimestamp + value
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, value, claimType);
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, value, extraData);
  }

  ///////////////////////////
  // groupId + groupTimestamp + claimType
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, groupTimestamp, claimType, extraData);
  }

  ///////////////////////////
  // groupId + groupTimestamp + extraData (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + value + claimType
  //////////////////////////
  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return ClaimRequestLib.build(groupId, value, claimType, extraData);
  }

  ///////////////////////////
  // groupId + value + extraData (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + claimType + extraData (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + groupTimestamp + value + claimType (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + groupTimestamp + value + extraData (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + groupTimestamp + claimType + extraData (all cases handled)
  //////////////////////////

  ///////////////////////////
  // groupId + value + claimType + extraData (all cases handled)
  //////////////////////////

  function buildAuth(
    AuthType authType,
    bool anonMode,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, anonMode, userId, extraData);
  }

  function buildAuth(AuthType authType) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType);
  }

  function buildAuth(AuthType authType, bool anonMode) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, anonMode);
  }

  function buildAuth(AuthType authType, uint256 userId) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, userId);
  }

  function buildAuth(AuthType authType, bytes memory extraData) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, extraData);
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    uint256 userId
  ) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, anonMode, userId);
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, anonMode, extraData);
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return AuthRequestLib.build(authType, userId, extraData);
  }

  function buildZkConnectRequest(
    DataRequest[] memory dataRequests,
    LogicalOperator operator
  ) public pure returns (ZkConnectRequestContent memory) {
    uint256 logicalOperatorsLength;
    if (dataRequests.length == 1) {
      logicalOperatorsLength = 1;
    } else {
      logicalOperatorsLength = dataRequests.length - 1;
    }

    LogicalOperator[] memory operators = new LogicalOperator[](logicalOperatorsLength);
    for (uint256 i = 0; i < operators.length; i++) {
      operators[i] = operator;
    }
    return ZkConnectRequestContent({dataRequests: dataRequests, operators: operators});
  }

  function buildZkConnectRequest(
    DataRequest[] memory dataRequests
  ) public pure returns (ZkConnectRequestContent memory) {
    ZkConnectRequestContentLib.build(dataRequests);
  }

  function buildZkConnectRequest(
    DataRequest memory dataRequest,
    LogicalOperator operator
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(dataRequest, operator);
  }

  function buildZkConnectRequest(
    DataRequest memory dataRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(dataRequest);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(claimRequest, authRequest, messageSignatureRequest);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    Auth memory authRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(claimRequest, authRequest);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest,
    bytes memory messageSignatureRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(claimRequest, messageSignatureRequest);
  }

  function buildZkConnectRequest(
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(authRequest, messageSignatureRequest);
  }

  function buildZkConnectRequest(
    Claim memory claimRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(claimRequest);
  }

  function buildZkConnectRequest(
    Auth memory authRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(authRequest);
  }

  function buildZkConnectRequest(
    bytes memory messageSignatureRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    return ZkConnectRequestContentLib.build(messageSignatureRequest);
  }
}
