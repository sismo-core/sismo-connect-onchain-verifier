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
  bytes public constant DEFAULT_MESSAGE_SIGNATURE_REQUEST = "";

  // default value for namespace
  bytes16 public constant DEFAULT_NAMESPACE = bytes16(keccak256("main"));

  function GET_DEFAULT_CLAIM_REQUEST() public pure returns (Claim memory) {
    return
      Claim({
        claimType: DEFAULT_CLAIM_TYPE,
        groupId: DEFAULT_CLAIM_GROUP_ID,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function GET_DEFAULT_AUTH_REQUEST() public pure returns (Auth memory) {
    return
      Auth({
        authType: AuthType.EMPTY,
        anonMode: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildClaim(
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

  function buildClaim(bytes16 groupId) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_VALUE,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, uint256 value) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_TYPE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) public pure returns (Claim memory) {
    return
      Claim({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        claimType: claimType,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) public pure returns (Claim memory) {
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
  ) public pure returns (Claim memory) {
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
    bool anonMode,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return Auth({authType: authType, anonMode: anonMode, userId: userId, extraData: extraData});
  }

  function buildAuth(AuthType authType) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, bool anonMode) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: anonMode,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, uint256 userId) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_AUTH_ANON_MODE,
        userId: userId,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, bytes memory extraData) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: extraData
      });
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    uint256 userId
  ) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: anonMode,
        userId: userId,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }

  function buildAuth(
    AuthType authType,
    bool anonMode,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: anonMode,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: extraData
      });
  }

  function buildAuth(
    AuthType authType,
    uint256 userId,
    bytes memory extraData
  ) public pure returns (Auth memory) {
    return
      Auth({
        authType: authType,
        anonMode: DEFAULT_AUTH_ANON_MODE,
        userId: userId,
        extraData: extraData
      });
  }

  function buildRequestContent(
    Claim memory claimRequest,
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public pure returns (ZkConnectRequestContent memory) {
    DataRequest[] memory dataRequests = new DataRequest[](1);
    dataRequests[0] = DataRequest({
      authRequest: authRequest,
      claimRequest: claimRequest,
      messageSignatureRequest: messageSignatureRequest
    });
    LogicalOperator[] memory operators = new LogicalOperator[](1);
    operators[0] = LogicalOperator.AND;

    return ZkConnectRequestContent({dataRequests: dataRequests, operators: operators});
  }

  function buildRequestContent(
    Claim memory claimRequest,
    Auth memory authRequest
  ) public returns (ZkConnectRequestContent memory) {
    return buildRequestContent(claimRequest, authRequest, DEFAULT_MESSAGE_SIGNATURE_REQUEST);
  }

  function buildRequestContent(
    Claim memory claimRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectRequestContent memory) {
    return buildRequestContent(claimRequest, GET_DEFAULT_AUTH_REQUEST(), messageSignatureRequest);
  }

  function buildRequestContent(
    Auth memory authRequest,
    bytes memory messageSignatureRequest
  ) public returns (ZkConnectRequestContent memory) {
    return buildRequestContent(GET_DEFAULT_CLAIM_REQUEST(), authRequest, messageSignatureRequest);
  }

  function buildRequestContent(
    Claim memory claimRequest
  ) public returns (ZkConnectRequestContent memory) {
    return buildRequestContent(claimRequest, GET_DEFAULT_AUTH_REQUEST());
  }

  function buildRequestContent(
    Auth memory authRequest
  ) public returns (ZkConnectRequestContent memory) {
    return buildRequestContent(GET_DEFAULT_CLAIM_REQUEST(), authRequest);
  }

  function buildRequest(
    Claim memory claim,
    Auth memory auth,
    bytes memory messageSignatureRequest,
    bytes16 appId,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: namespace,
        content: buildRequestContent(claim, auth, messageSignatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    bytes memory messageSignatureRequest,
    bytes16 appId,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: namespace,
        content: buildRequestContent(claim, messageSignatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    Auth memory auth,
    bytes16 appId,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: namespace,
        content: buildRequestContent(claim, auth)
      })
    );
  }

  function buildRequest(
    Auth memory auth,
    bytes memory messageSignatureRequest,
    bytes16 appId,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: namespace,
        content: buildRequestContent(auth, messageSignatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    bytes16 appId,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: namespace,
        content: buildRequestContent(claim, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Auth memory auth,
    bytes16 appId,
    bytes16 namespace
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: namespace,
        content: buildRequestContent(auth, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    Auth memory auth,
    bytes memory messageSignatureRequest,
    bytes16 appId
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: buildRequestContent(claim, auth, messageSignatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    bytes memory messageSignatureRequest,
    bytes16 appId
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: buildRequestContent(claim, messageSignatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    Auth memory auth,
    bytes16 appId
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: buildRequestContent(claim, auth)
      })
    );
  }

  function buildRequest(
    Auth memory auth,
    bytes memory messageSignatureRequest,
    bytes16 appId
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: buildRequestContent(auth, messageSignatureRequest)
      })
    );
  }

  function buildRequest(
    Claim memory claim,
    bytes16 appId
  ) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: buildRequestContent(claim, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }

  function buildRequest(Auth memory auth, bytes16 appId) public returns (ZkConnectRequest memory) {
    return (
      ZkConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        content: buildRequestContent(auth, DEFAULT_MESSAGE_SIGNATURE_REQUEST)
      })
    );
  }
}
