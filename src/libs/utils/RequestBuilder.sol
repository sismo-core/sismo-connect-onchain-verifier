// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

library RequestBuilder {
  // default value for Claim
  bytes16 public constant DEFAULT_CLAIM_GROUP_TIMESTAMP = bytes16("latest");
  uint256 public constant DEFAULT_CLAIM_VALUE = 1;
  bytes16 public constant DEFAULT_CLAIM_GROUP_ID = "";
  ClaimType public constant DEFAULT_CLAIM_TYPE = ClaimType.GTE;
  bytes public constant DEFAULT_CLAIM_EXTRA_DATA = "";

  // default values for Auth
  bool public constant DEFAULT_AUTH_ANON_MODE = false;
  uint256 public constant DEFAULT_AUTH_USER_ID = 0;
  bytes public constant DEFAULT_AUTH_EXTRA_DATA = "";

  // default values for MessageSignature
  bytes public constant DEFAULT_MESSAGE_SIGNATURE_REQUEST = "MESSAGE_SELECTED_BY_USER";

  // default value for namespace
  bytes16 public constant DEFAULT_NAMESPACE = bytes16(keccak256("main"));

  function GET_EMPTY_CLAIM_REQUEST() public pure returns (Claim memory) {
    return
      Claim({
        claimType: ClaimType.EMPTY,
        groupId: DEFAULT_CLAIM_GROUP_ID,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        isOptional: false,
        isSelectableByUser: false,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function GET_EMPTY_AUTH_REQUEST() public pure returns (Auth memory) {
    return
      Auth({
        authType: AuthType.EMPTY,
        isAnon: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        isOptional: false,
        isSelectableByUser: false,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: claimType,
        extraData: extraData
      });
  }

  function buildClaim(bytes16 groupId) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, uint256 value) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: value,
        claimType: claimType,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: claimType,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: value,
        claimType: claimType,
        extraData: extraData
      });
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return Auth({authType: authType, isAnon: isAnon, userId: userId, extraData: extraData});
  }

  function buildAuth(AuthType authType) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, bool isAnon) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, uint256 userId) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_ANON_MODE,
        userId: userId,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, bytes memory extraData) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: extraData
      });
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    uint256 userId
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: userId,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(
    AuthType authType,
    bool isAnon,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: extraData
      });
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) external pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        isAnon: DEFAULT_AUTH_ANON_MODE,
        userId: userId,
        extraData: extraData
      });
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        authRequests: [authRequest],
        claimRequests: [claimRequest],
        signatureRequest: signatureRequest
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes memory signatureRequest,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        content: _buildRequestContent(claimRequest, GET_EMPTY_AUTH_REQUEST(), signatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        content: _buildRequestContent(claimRequest, authRequest, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        content: _buildRequestContent(GET_EMPTY_CLAIM_REQUEST(), authRequest, signatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        content: _buildRequestContent(claimRequest, GET_EMPTY_AUTH_REQUEST(), DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Auth memory authRequest,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        content: _buildRequestContent(GET_EMPTY_CLAIM_REQUEST(), authRequest, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: _buildRequestContent(claimRequest, authRequest, signatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes memory signatureRequest,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: _buildRequestContent(claimRequest, GET_EMPTY_AUTH_REQUEST(), signatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: _buildRequestContent(claimRequest, authRequest, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Auth memory authRequest,
    bytes memory signatureRequest,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: _buildRequestContent(GET_EMPTY_CLAIM_REQUEST(), authRequest, signatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claimRequest,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: _buildRequestContent(claimRequest, GET_EMPTY_AUTH_REQUEST(), DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Auth memory authRequest,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: _buildRequestContent(GET_EMPTY_CLAIM_REQUEST(), authRequest, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }
}
