// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

library RequestBuilder {
  // default value for Claim Request
  bytes16 public constant DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP = bytes16("latest");
  uint256 public constant DEFAULT_CLAIM_REQUEST_VALUE = 1;
  ClaimType public constant DEFAULT_CLAIM_REQUEST_TYPE = ClaimType.GTE;
  bool public constant DEFAULT_CLAIM_REQUEST_IS_OPTIONAL = false;
  bool public constant DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER = true;
  bytes public constant DEFAULT_CLAIM_REQUEST_EXTRA_DATA = "";

  // default values for Auth Request
  bool public constant DEFAULT_AUTH_REQUEST_IS_ANON = false;
  uint256 public constant DEFAULT_AUTH_REQUEST_USER_ID = 0;
  bool public constant DEFAULT_AUTH_REQUEST_IS_OPTIONAL = false;
  bool public constant DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER = true;
  bytes public constant DEFAULT_AUTH_REQUEST_EXTRA_DATA = "";

  // default values for Signature Request
  bytes public constant DEFAULT_SIGNATURE_REQUEST_MESSAGE = "MESSAGE_SELECTED_BY_USER";
  bool public constant DEFAULT_SIGNATURE_REQUEST_IS_SELECTABLE_BY_USER = false;
  bytes public constant DEFAULT_SIGNATURE_REQUEST_EXTRA_DATA = "";

  // default value for namespace
  bytes16 public constant DEFAULT_NAMESPACE = bytes16(keccak256("main"));

  function GET_EMPTY_SIGNATURE_REQUEST() external pure returns (SignatureRequest memory) {
    return _GET_EMPTY_SIGNATURE_REQUEST();
  }

  function _GET_EMPTY_SIGNATURE_REQUEST() internal pure returns (SignatureRequest memory) {
    return
      SignatureRequest({
        message: DEFAULT_SIGNATURE_REQUEST_MESSAGE,
        isSelectableByUser: DEFAULT_SIGNATURE_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_SIGNATURE_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bool isOptional,
    bool isSelectableByUser,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        claimType: claimType,
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        isOptional: isOptional,
        isSelectableByUser: isSelectableByUser,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        claimType: claimType,
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(bytes16 groupId) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, bytes16 groupTimestamp) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, uint256 value) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, ClaimType claimType) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(bytes16 groupId, bytes memory extraData) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: value,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: value,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    ClaimType claimType
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_CLAIM_REQUEST_EXTRA_DATA
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    uint256 value,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: value,
        claimType: DEFAULT_CLAIM_REQUEST_TYPE,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    bytes16 groupTimestamp,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: groupTimestamp,
        value: DEFAULT_CLAIM_REQUEST_VALUE,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildClaim(
    bytes16 groupId,
    uint256 value,
    ClaimType claimType,
    bytes memory extraData
  ) external pure returns (ClaimRequest memory) {
    return
      ClaimRequest({
        groupId: groupId,
        groupTimestamp: DEFAULT_CLAIM_REQUEST_GROUP_TIMESTAMP,
        value: value,
        claimType: claimType,
        isOptional: DEFAULT_CLAIM_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_CLAIM_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: extraData
      });
  }

  function buildAuth(
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

  function buildAuth(AuthType authType, bool isAnon, uint256 userId, bytes memory extraData) external pure returns (AuthRequest memory) {
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

  function buildAuth(AuthType authType) external pure returns (AuthRequest memory) {
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

  function buildAuth(AuthType authType, bool isAnon) external pure returns (AuthRequest memory) {
    return
      AuthRequest({
        authType: authType,
        isAnon: isAnon,
        userId: DEFAULT_AUTH_REQUEST_USER_ID,
        isOptional: DEFAULT_AUTH_REQUEST_IS_OPTIONAL,
        isSelectableByUser: DEFAULT_AUTH_REQUEST_IS_SELECTABLE_BY_USER,
        extraData: DEFAULT_AUTH_REQUEST_EXTRA_DATA
      });
  }

  function buildAuth(AuthType authType, uint256 userId) external pure returns (AuthRequest memory) {
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

  function buildAuth(AuthType authType, bytes memory extraData) external pure returns (AuthRequest memory) {
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

  function buildAuth(
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

  function buildAuth(
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

  function buildAuth(
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

  function buildSignature(bytes memory message) external pure returns (SignatureRequest memory) {
    return SignatureRequest({message: message, isSelectableByUser: DEFAULT_SIGNATURE_REQUEST_IS_SELECTABLE_BY_USER, extraData: DEFAULT_SIGNATURE_REQUEST_EXTRA_DATA});
  }

  function buildSignature(bytes memory message, bool isSelectableByUser) external pure returns (SignatureRequest memory) {
    return SignatureRequest({message: message, isSelectableByUser: isSelectableByUser, extraData: DEFAULT_SIGNATURE_REQUEST_EXTRA_DATA});
  }

  function buildSignature(bytes memory message, bytes memory extraData) external pure returns (SignatureRequest memory) {
    return SignatureRequest({message: message, isSelectableByUser: DEFAULT_SIGNATURE_REQUEST_IS_SELECTABLE_BY_USER, extraData: extraData});
  }


  function buildSignature(bytes memory message, bool isSelectableByUser, bytes memory extraData) external pure returns (SignatureRequest memory) {
    return SignatureRequest({message: message, isSelectableByUser: isSelectableByUser, extraData: extraData});
  }

  function buildSignature(bool isSelectableByUser) external pure returns (SignatureRequest memory) {
    return SignatureRequest({message: DEFAULT_SIGNATURE_REQUEST_MESSAGE, isSelectableByUser: isSelectableByUser, extraData: DEFAULT_SIGNATURE_REQUEST_EXTRA_DATA});
  }

  function buildSignature(bool isSelectableByUser, bytes memory extraData) external pure returns (SignatureRequest memory) {
    return SignatureRequest({message: DEFAULT_SIGNATURE_REQUEST_MESSAGE, isSelectableByUser: isSelectableByUser, extraData: extraData});
  }

  function buildRequest(
    ClaimRequest memory claim,
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    AuthRequest memory auth,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }


  function buildRequest(
    ClaimRequest memory claim,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }


  function buildRequest(
    ClaimRequest memory claim,
    AuthRequest memory auth,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  // buildRequest with arrays for auths and claims
  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    AuthRequest[] memory auths,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    AuthRequest[] memory auths,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }
}
