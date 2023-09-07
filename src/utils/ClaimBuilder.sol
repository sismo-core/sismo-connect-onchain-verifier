// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";

library ClaimBuilder {
  // default value for Claim Request
  bytes16 public constant DEFAULT_CLAIM_GROUP_TIMESTAMP = bytes16("latest");
  uint256 public constant DEFAULT_CLAIM_VALUE = 1;
  ClaimType public constant DEFAULT_CLAIM_TYPE = ClaimType.GTE;
  bool public constant DEFAULT_CLAIM_IS_SELECTABLE_BY_USER = true;
  bytes public constant DEFAULT_CLAIM_EXTRA_DATA = "";

  function build(bytes16 groupId) internal pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        isSelectableByUser: DEFAULT_CLAIM_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function build(bytes16 groupId, bytes16 groupTimestamp) internal pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        isSelectableByUser: DEFAULT_CLAIM_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function build(bytes16 groupId, ClaimType claimType) internal pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        isSelectableByUser: DEFAULT_CLAIM_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function build(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) internal pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        isSelectableByUser: DEFAULT_CLAIM_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }
}
