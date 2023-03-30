// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

library ClaimRequestLib {
  bytes16 public constant DEFAULT_GROUP_TIMESTAMP = bytes16("latest");
  uint256 public constant DEFAULT_VALUE = 1;
  ClaimType public constant DEFAULT_CLAIM_TYPE = ClaimType.GTE;
  bytes public constant DEFAULT_EXTRA_DATA = "";

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: claimType,
        extraData: extraData
      });
  }

  function build(bytes16 groupId) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: DEFAULT_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(bytes16 groupId, bytes16 groupTimestamp) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(bytes16 groupId, uint256 value) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(bytes16 groupId, ClaimType claimType) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: DEFAULT_VALUE,
        claimType: claimType,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(bytes16 groupId, bytes memory extraData) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: DEFAULT_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_VALUE,
        claimType: claimType,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function build(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: value,
        claimType: claimType,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function build(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: DEFAULT_VALUE,
        claimType: claimType,
        extraData: extraData
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: claimType,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_VALUE,
        claimType: claimType,
        extraData: extraData
      });
  }

  function build(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_GROUP_TIMESTAMP,
        value: value,
        claimType: claimType,
        extraData: extraData
      });
  }
}
