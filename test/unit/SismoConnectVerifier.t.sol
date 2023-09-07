// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {ResponseBuilder, ResponseWithoutProofs} from "test/utils/ResponseBuilderLib.sol";
import {VerifierMockBaseTest} from "test/verifiers/mocks/VerifierMockBaseTest.t.sol";
import {BaseDeploymentConfig} from "script/BaseConfig.sol";
import {AuthBuilder} from "src/utils/AuthBuilder.sol";
import {ClaimBuilder} from "src/utils/ClaimBuilder.sol";
import "src/utils/Structs.sol";
import "src/utils/Fmt.sol";

contract SismoConnectVerifierTest is VerifierMockBaseTest {
  using ResponseBuilder for SismoConnectResponse;
  using ResponseBuilder for ResponseWithoutProofs;

  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;

  // default values for tests
  bytes16 public DEFAULT_APP_ID = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 public DEFAULT_NAMESPACE = bytes16(keccak256("main"));
  bytes32 public DEFAULT_VERSION = bytes32("sismo-connect-v1.1");
  bytes public DEFAULT_SIGNED_MESSAGE = abi.encode(user);

  bool public DEFAULT_IS_IMPERSONATION_MODE = false;

  bytes32 public DEFAULT_PROVING_SCHEME = bytes32("mock-scheme");

  ResponseWithoutProofs public DEFAULT_RESPONSE =
    ResponseBuilder
      .emptyResponseWithoutProofs()
      .withAppId(DEFAULT_APP_ID)
      .withVersion(DEFAULT_VERSION)
      .withNamespace(DEFAULT_NAMESPACE)
      .withSignedMessage(DEFAULT_SIGNED_MESSAGE);

  AuthRequest public DEFAULT_AUTH_REQUEST;
  ClaimRequest public DEFAULT_CLAIM_REQUEST;
  SignatureRequest public DEFAULT_SIGNATURE_REQUEST;
  SismoConnectConfig public DEFAULT_SISMO_CONNECT_CONFIG;

  function setUp() public virtual override {
    VerifierMockBaseTest.setUp();

    DEFAULT_AUTH_REQUEST = AuthRequest({
      authType: AuthType.VAULT,
      userId: 0,
      isAnon: false,
      isOptional: false,
      isSelectableByUser: false,
      extraData: ""
    });
    DEFAULT_CLAIM_REQUEST = ClaimRequest({
      groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
      groupTimestamp: bytes16("latest"),
      claimType: ClaimType.GTE,
      value: 1,
      isOptional: false,
      isSelectableByUser: true,
      extraData: ""
    });
    DEFAULT_SIGNATURE_REQUEST = SignatureRequest({
      message: abi.encode(user),
      isSelectableByUser: false,
      extraData: ""
    });
    DEFAULT_SISMO_CONNECT_CONFIG = SismoConnectConfig({
      appId: DEFAULT_APP_ID,
      vault: VaultConfig({isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE})
    });
  }

  // Tests that should revert

  function test_RevertWith_VersionMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withVersion(bytes32("wrong-version"))
      .build();

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: DEFAULT_AUTH_REQUEST,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "VersionMismatch(bytes32,bytes32)",
        invalidResponse.version,
        DEFAULT_VERSION
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_NamespaceMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withNamespace(bytes16(keccak256("wrong-namespace")))
      .build();

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: DEFAULT_AUTH_REQUEST,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "NamespaceMismatch(bytes16,bytes16)",
        invalidResponse.namespace,
        DEFAULT_NAMESPACE
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AppIdMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withAppId("wrong-app-id")
      .build();

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: DEFAULT_AUTH_REQUEST,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "AppIdMismatch(bytes16,bytes16)",
        invalidResponse.appId,
        DEFAULT_APP_ID
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_SignatureMessageMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withSignedMessage("wrong-signed-message")
      .build();

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: DEFAULT_AUTH_REQUEST,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "SignatureMessageMismatch(bytes,bytes)",
        DEFAULT_SIGNATURE_REQUEST.message,
        invalidResponse.signedMessage
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthInRequestNotFoundInResponse() public {
    // we expect a revert since no proofs are provided in the response
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.build();

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: DEFAULT_AUTH_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthInRequestNotFoundInResponse(uint8,bool,uint256,bytes)",
        DEFAULT_AUTH_REQUEST.authType,
        DEFAULT_AUTH_REQUEST.isAnon,
        DEFAULT_AUTH_REQUEST.userId,
        DEFAULT_AUTH_REQUEST.extraData
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthIsAnonAndUserIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.GITHUB, isAnon: true, userId: uint256(0xc0de)})
    });
    // we need to choose a different AuthType than AUthType.VAULT to be able to test if the userId error is thrown
    // we also need to set the userId different from zero since isSelectableByUser is false
    // it means that we are waiting for a userId in the response that actually means something so different from zero
    // we set userId of the request to 0xf00 to be different from the one in the response
    AuthRequest memory githubAuth = AuthRequest({
      authType: AuthType.GITHUB,
      userId: uint256(0xf00),
      isAnon: false,
      isOptional: false,
      isSelectableByUser: false,
      extraData: ""
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: githubAuth,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthIsAnonAndUserIdNotFound(bool,uint256)",
        githubAuth.isAnon,
        githubAuth.userId
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthTypeAndUserIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      // we choose an arbitrary userId different from zero in the response to specify that we are waiting for a userId
      auth: AuthBuilder.build({authType: AuthType.VAULT, userId: uint256(0xc0de)})
    });
    // we need to choose a different AuthType than AUthType.VAULT to be able to test if the userId error is thrown
    // we set userId of the request to 0xf00 to be different from the one in the response
    AuthRequest memory githubAuth = AuthRequest({
      authType: AuthType.GITHUB,
      // wrong userId
      userId: uint256(0xf00),
      isAnon: false,
      isOptional: false,
      isSelectableByUser: false,
      extraData: ""
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: githubAuth,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthTypeAndUserIdNotFound(uint8,uint256)",
        githubAuth.authType,
        githubAuth.userId
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthUserIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      // we choose an arbitrary userId different from zero in the response to specify that we are waiting for a userId
      auth: AuthBuilder.build({authType: AuthType.GITHUB, userId: uint256(0xc0de)})
    });
    // we need to choose a different AuthType than AUthType.VAULT to be able to test if the userId error is thrown
    // we set userId of the request to 0xf00 to be different from the one in the response
    AuthRequest memory githubAuth = AuthRequest({
      authType: AuthType.GITHUB,
      // wrong userId
      userId: uint256(0xf00),
      isAnon: false,
      isOptional: false,
      isSelectableByUser: false,
      extraData: ""
    });
    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: githubAuth,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(abi.encodeWithSignature("AuthUserIdNotFound(uint256)", githubAuth.userId));
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthTypeAndIsAnonNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT, isAnon: true})
    });

    AuthRequest memory githubAuth = AuthRequest({
      authType: AuthType.GITHUB,
      userId: 0,
      isAnon: false,
      isOptional: false,
      isSelectableByUser: true,
      extraData: ""
    });
    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: githubAuth,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthTypeAndIsAnonNotFound(uint8,bool)",
        githubAuth.authType,
        githubAuth.isAnon
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthIsAnonNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT, isAnon: true})
    });

    AuthRequest memory vaultAuth = AuthRequest({
      authType: AuthType.VAULT,
      userId: 0,
      isAnon: false,
      isOptional: false,
      isSelectableByUser: false,
      extraData: ""
    });
    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: vaultAuth,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(abi.encodeWithSignature("AuthIsAnonNotFound(bool)", vaultAuth.isAnon));
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_AuthTypeNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT})
    });

    AuthRequest memory githubAuth = AuthRequest({
      authType: AuthType.GITHUB,
      userId: 0,
      isAnon: false,
      isOptional: false,
      isSelectableByUser: true,
      extraData: ""
    });
    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: githubAuth,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(abi.encodeWithSignature("AuthTypeNotFound(uint8)", githubAuth.authType));
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimInRequestNotFoundInResponse() public {
    // we expect a revert since no proofs are provided in the response
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.build();

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimInRequestNotFoundInResponse(uint8,bytes16,bytes16,uint256,bytes)",
        DEFAULT_CLAIM_REQUEST.claimType,
        DEFAULT_CLAIM_REQUEST.groupId,
        DEFAULT_CLAIM_REQUEST.groupTimestamp,
        DEFAULT_CLAIM_REQUEST.value,
        DEFAULT_CLAIM_REQUEST.extraData
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimGroupIdAndGroupTimestampNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({
        groupId: "wrong-group-id",
        groupTimestamp: bytes16("wrong-timestamp")
      })
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimGroupIdAndGroupTimestampNotFound(bytes16,bytes16)",
        DEFAULT_CLAIM_REQUEST.groupId,
        DEFAULT_CLAIM_REQUEST.groupTimestamp
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimTypeAndGroupTimestampNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({
        groupId: DEFAULT_CLAIM_REQUEST.groupId,
        groupTimestamp: bytes16("fake-timestamp"),
        claimType: ClaimType.LTE
      })
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeAndGroupTimestampNotFound(uint8,bytes16)",
        DEFAULT_CLAIM_REQUEST.claimType,
        DEFAULT_CLAIM_REQUEST.groupTimestamp
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimGroupTimestampNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({
        groupId: DEFAULT_CLAIM_REQUEST.groupId,
        groupTimestamp: bytes16("wrong-timestamp")
      })
    });
    invalidResponse.proofs[0].claims[0].groupTimestamp = bytes16("fake-timestamp");

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimGroupTimestampNotFound(bytes16)",
        DEFAULT_CLAIM_REQUEST.groupTimestamp
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimTypeAndGroupIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: "wrong-id", claimType: ClaimType.LTE})
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeAndGroupIdNotFound(uint8,bytes16)",
        DEFAULT_CLAIM_REQUEST.claimType,
        DEFAULT_CLAIM_REQUEST.groupId
      )
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimGroupIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: bytes16("wrong-group-id")})
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature("ClaimGroupIdNotFound(bytes16)", DEFAULT_CLAIM_REQUEST.groupId)
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_RevertWith_ClaimTypeNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: DEFAULT_CLAIM_REQUEST.groupId, claimType: ClaimType.LTE})
    });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    vm.expectRevert(
      abi.encodeWithSignature("ClaimTypeNotFound(uint8)", uint8(DEFAULT_CLAIM_REQUEST.claimType))
    );
    sismoConnectVerifier.verify({
      response: invalidResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  function test_OneAuthOneClaimOneSignature() public view {
    SismoConnectResponse memory validResponse = DEFAULT_RESPONSE
      .withAuth({
        auth: AuthBuilder.build({authType: AuthType.VAULT}),
        provingScheme: DEFAULT_PROVING_SCHEME
      })
      .withClaim({
        claim: ClaimBuilder.build({groupId: DEFAULT_CLAIM_REQUEST.groupId}),
        provingScheme: DEFAULT_PROVING_SCHEME
      });

    SismoConnectRequest memory request = buildSismoConnectRequest({
      auth: DEFAULT_AUTH_REQUEST,
      claim: DEFAULT_CLAIM_REQUEST,
      signature: DEFAULT_SIGNATURE_REQUEST,
      namespace: DEFAULT_NAMESPACE
    });

    sismoConnectVerifier.verify({
      response: validResponse,
      request: request,
      config: DEFAULT_SISMO_CONNECT_CONFIG
    });
  }

  // helpers

  function emptyResponse() private pure returns (SismoConnectResponse memory) {
    return ResponseBuilder.empty();
  }

  function buildSismoConnectRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) private pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        namespace: namespace
      });
  }

  function buildSismoConnectRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 namespace
  ) private pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    return
      SismoConnectRequest({
        auths: auths,
        claims: new ClaimRequest[](0),
        signature: signature,
        namespace: namespace
      });
  }

  function buildSismoConnectRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 namespace
  ) private pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return
      SismoConnectRequest({
        auths: new AuthRequest[](0),
        claims: claims,
        signature: signature,
        namespace: namespace
      });
  }
}
