// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

library AuthRequestLib {
  bool public constant DEFAULT_ANON_MODE = false;
  uint256 public constant DEFAULT_USER_ID = 0;
  bytes public constant DEFAULT_EXTRA_DATA = "";

  function build(
    AuthType authType,
    bool anonMode,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return Auth({authType: authType, anonMode: anonMode, userId: userId, extraData: extraData});
  }

  function build(AuthType authType) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_ANON_MODE,
        userId: DEFAULT_USER_ID,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(AuthType authType, bool anonMode) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: anonMode,
        userId: DEFAULT_USER_ID,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(AuthType authType, uint256 userId) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_ANON_MODE,
        userId: userId,
        extraData: DEFAULT_EXTRA_DATA
      });
  }

  function build(AuthType authType, bytes memory extraData) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_ANON_MODE,
        userId: DEFAULT_USER_ID,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    bool anonMode,
    uint256 userId
  ) public pure returns (Auth memory) {
    return
      Auth({authType: authType, anonMode: anonMode, userId: userId, extraData: DEFAULT_EXTRA_DATA});
  }

  function build(
    AuthType authType,
    bool anonMode,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return
      Auth({authType: authType, anonMode: anonMode, userId: DEFAULT_USER_ID, extraData: extraData});
  }

  function build(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return
      Auth({authType: authType, anonMode: DEFAULT_ANON_MODE, userId: userId, extraData: extraData});
  }
}
