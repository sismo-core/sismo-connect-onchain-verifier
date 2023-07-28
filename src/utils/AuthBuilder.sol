// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";

library AuthBuilder {
  // default values for Auth Request
  AuthType public constant DEFAULT_AUTH_TYPE = AuthType.VAULT;
  bool public constant DEFAULT_AUTH_IS_ANON = false;
  uint256 public constant DEFAULT_AUTH_USER_ID = 0;
  bool public constant DEFAULT_AUTH_IS_SELECTABLE_BY_USER = true;
  bytes public constant DEFAULT_AUTH_EXTRA_DATA = "";

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isSelectableByUser: isSelectableByUser,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(AuthType authType) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_IS_ANON,
        userId: DEFAULT_AUTH_USER_ID,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function build(AuthType authType, bool isAnon) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_USER_ID,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function build(AuthType authType, uint256 userId) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_IS_ANON,
        userId: userId,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function build(AuthType authType, bytes memory extraData) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_IS_ANON,
        userId: DEFAULT_AUTH_USER_ID,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_USER_ID,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_IS_ANON,
        userId: userId,
        isSelectableByUser: DEFAULT_AUTH_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bool isSelectableByUser
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isSelectableByUser: isSelectableByUser,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }
}
