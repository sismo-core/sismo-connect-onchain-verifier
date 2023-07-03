// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "src/libs/sismo-connect/SismoConnectLib.sol";

contract UpgradeableExample is SismoConnect, Initializable {
  bytes16[] private _groupIds;

  constructor(
    bytes16 appId,
    bool isImpersonationMode,
    bytes16 groupId
  ) SismoConnect(buildConfig(appId, isImpersonationMode)) {
    initialize(groupId);
  }

  function initialize(bytes16 groupId) public initializer {
    _groupIds.push(groupId);
  }

  function addGroupId(bytes16 groupId) public {
    _groupIds.push(groupId);
  }

  function getGroupIds() public view returns (bytes16[] memory) {
    return _groupIds;
  }

  function exposed_buildSignature(
    bytes memory message
  ) external view returns (SignatureRequest memory) {
    return buildSignature(message);
  }

  function exposed_verify(
    bytes memory responseBytes,
    SignatureRequest memory signature
  ) external returns (SismoConnectVerifiedResult memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](_groupIds.length);
    for (uint256 i = 0; i < _groupIds.length; i++) {
      claims[i] = buildClaim(_groupIds[i]);
    }
    return verify({responseBytes: responseBytes, claims: claims, signature: signature});
  }
}
