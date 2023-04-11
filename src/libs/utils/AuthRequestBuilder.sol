// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

library AuthRequestBuilder {
   // default values for Auth Request
  bool public constant DEFAULT_AUTH_REQUEST_IS_ANON = false;
  uint256 public constant DEFAULT_AUTH_REQUEST_USER_ID = 0;
  bool public constant DEFAULT_AUTH_REQUEST_IS_OPTIONAL = false;
  bool public constant DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER = true;
  bytes public constant DEFAULT_AUTH_REQUEST_EXTRA_DATA = "";

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bool isOptional,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (AuthRequest memory) {
    return AuthRequest({
      authType: authType, 
      isAnon: isAnon, 
      userId: userId, 
      isOptional: isOptional,
      isSelectableByUser: isSelectableByUser,
      extraData: extraData
    });
  }

  function build(AuthType authType, bool isAnon, uint256 userId, bytes memory extraData) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(AuthType authType) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: DEFAULT_AUTH_REQUEST_IS_ANON,
        userId: DEFAULT_AUTH_REQUEST_USER_ID,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  // we comment this function because it has the same signature as build(AuthType authType, bool isOptional)
  // but this one is not used for now since the anonymous auth is not implemented
  
  // function build(AuthType authType, bool isAnon) external pure returns (AuthRequest memory) {
  //   return
  //     AuthRequest({
  //       authType: authType,
  //       isAnon: isAnon,
  //       userId: DEFAULT_AUTH_REQUEST_USER_ID,
  //       isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
  //       isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
  //       extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
  //     });
  // }

  function build(AuthType authType, uint256 userId) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: DEFAULT_AUTH_REQUEST_IS_ANON,
        userId: userId,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  function build(AuthType authType, bytes memory extraData) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: DEFAULT_AUTH_REQUEST_IS_ANON,
        userId: DEFAULT_AUTH_REQUEST_USER_ID,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_REQUEST_USER_ID,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function build(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: DEFAULT_AUTH_REQUEST_IS_ANON,
        userId: userId,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  // allow dev to choose for isOptional

  function build(
    AuthType authType,
    bool isOptional
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: DEFAULT_AUTH_REQUEST_IS_ANON,
        userId: DEFAULT_AUTH_REQUEST_USER_ID,
        isOptional: isOptional,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    bool isOptional
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_REQUEST_USER_ID,
        isOptional: isOptional,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  function build(
    AuthType authType,
    uint256 userId,
    bool isOptional
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: DEFAULT_AUTH_REQUEST_IS_ANON,
        userId: userId,
        isOptional: isOptional,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  function build(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bool isOptional
  ) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        isOptional: isOptional,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }
}