// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/libs/utils/Fmt.sol";
import {VerifierMockBaseTest} from "test/verifiers/mocks/VerifierMockBaseTest.t.sol";
import {SismoConnect, RequestBuilder, ClaimRequestBuilder} from "src/libs/sismo-connect/SismoConnectLib.sol";
import {ZKDropERC721} from "src/ZKDropERC721.sol";
import "src/libs/utils/Structs.sol";
import {SismoConnectHarness} from "test/harness/SismoConnectHarness.sol";

import {AuthBuilder} from "src/libs/utils/AuthBuilder.sol";
import {ClaimBuilder} from "src/libs/utils/ClaimBuilder.sol";
import {ResponseBuilder, ResponseWithoutProofs} from "test/utils/ResponseBuilderLib.sol";
import {BaseDeploymentConfig} from "script/BaseConfig.sol";

contract SismoConnectLibTest is VerifierMockBaseTest {
  using ResponseBuilder for SismoConnectResponse;
  using ResponseBuilder for ResponseWithoutProofs;

  SismoConnectHarness sismoConnect;
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

  ClaimRequest claimRequest;
  AuthRequest authRequest;
  SignatureRequest signature;

  bytes16 immutable APP_ID_ZK_DROP = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 immutable ZK = 0xe9ed316946d3d98dfcd829a53ec9822e;
  ZKDropERC721 zkdrop;

  function setUp() public virtual override {
    super.setUp();
    sismoConnect = new SismoConnectHarness(DEFAULT_APP_ID, DEFAULT_IS_IMPERSONATION_MODE);
    claimRequest = sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    authRequest = sismoConnect.exposed_buildAuth({authType: AuthType.VAULT});
    signature = sismoConnect.exposed_buildSignature({message: abi.encode(user)});

    zkdrop = new ZKDropERC721({
      appId: APP_ID_ZK_DROP,
      groupId: ZK,
      name: "ZKDrop test",
      symbol: "test",
      baseTokenURI: "https://test.com"
    });
    console.log("ZkDrop contract deployed at", address(zkdrop));
  }

  // Tests that should revert

  function test_RevertWith_EmptyMessageIfSismoConnectResponseIsEmpty() public {
    bytes memory responseBytes = hex"";
    // we just expect a revert with an empty responseBytes as far as the decoding will not be successful
    vm.expectRevert();
    sismoConnect.exposed_verify({responseBytes: responseBytes, claim: claimRequest});
  }

  function test_RevertWith_InvalidUserIdAndIsSelectableByUserAuthType() public {
    // When `userId` is 0, it means the app does not require a specific auth account and the user needs
    // to choose the account they want to use for the app.
    // When `isSelectableByUser` is true, the user can select the account they want to use.
    // The combination of `userId = 0` and `isSelectableByUser = false` does not make sense and should not be used.

    // Here we do expect the revert since we set isSelectableByUser to false
    // and we keep the default value for userId which is 0
    // effectivelly triggering the revert
    // Note: we use an AuthType different from VAULT to not trigger another revert
    vm.expectRevert(abi.encodeWithSignature("InvalidUserIdAndIsSelectableByUserAuthType()"));
    sismoConnect.exposed_buildAuth({
      authType: AuthType.GITHUB,
      isOptional: false,
      isSelectableByUser: false
    });
  }

  function test_RevertWith_InvalidUserIdAndAuthType() public {
    // When `userId` is 0, it means the app does not require a specific auth account and the user needs
    // to choose the account they want to use for the app.
    // When `isSelectableByUser` is true, the user can select the account they want to use.
    // The combination of `userId = 0` and `isSelectableByUser = false` does not make sense and should not be used.

    // Here we set isSelectableByUser to false but we add a userId different from zero
    // while choosing The AuthType VAULT, which does NOT make sense since it states that we allow the user to choose a vault account in his vault
    // but in the case of the AuthType VAULT, the account is the vault itself and therefore there is no choice to make
    // we should definitely revert based on this reasoning
    vm.expectRevert(abi.encodeWithSignature("InvalidUserIdAndAuthType()"));
    sismoConnect.exposed_buildAuth({
      authType: AuthType.VAULT,
      isOptional: false,
      isSelectableByUser: false,
      userId: uint256(bytes32("wrong-id"))
    });
  }

  function test_RevertWith_VersionMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withVersion(bytes32("wrong-version"))
      .build();
    vm.expectRevert(
      abi.encodeWithSignature(
        "VersionMismatch(bytes32,bytes32)",
        invalidResponse.version,
        DEFAULT_VERSION
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest});
  }

  function test_RevertWith_NamespaceMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withNamespace(bytes16(keccak256("wrong-namespace")))
      .build();

    vm.expectRevert(
      abi.encodeWithSignature(
        "NamespaceMismatch(bytes16,bytes16)",
        invalidResponse.namespace,
        DEFAULT_NAMESPACE
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest});
  }

  function test_RevertWith_AppIdMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAppId("wrong-id").build();
    vm.expectRevert(
      abi.encodeWithSignature(
        "AppIdMismatch(bytes16,bytes16)",
        invalidResponse.appId,
        DEFAULT_APP_ID
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest});
  }

  function test_RevertWith_SignatureMessageMismatch() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE
      .withSignedMessage("wrong-signed-message")
      .build();
    vm.expectRevert(
      abi.encodeWithSignature(
        "SignatureMessageMismatch(bytes,bytes)",
        signature.message,
        invalidResponse.signedMessage
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_AuthInRequestNotFoundInResponse() public {
    // we expect a revert since no proofs are provided in the response
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.build();
    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthInRequestNotFoundInResponse(uint8,bool,uint256,bytes)",
        authRequest.authType,
        authRequest.isAnon,
        authRequest.userId,
        authRequest.extraData
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: authRequest,
      signature: signature
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
    AuthRequest memory auth = sismoConnect.exposed_buildAuth({
      authType: AuthType.GITHUB,
      isOptional: false,
      isSelectableByUser: false,
      userId: uint256(0xf00)
    });

    vm.expectRevert(
      abi.encodeWithSignature("AuthIsAnonAndUserIdNotFound(bool,uint256)", auth.isAnon, auth.userId)
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: auth,
      signature: signature
    });
  }

  function test_RevertWith_AuthTypeAndUserIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT, userId: uint256(bytes32("wrong-id"))})
    });
    // we need to choose a different AuthType than AUthType.VAULT to be able to test if the userId error is thrown
    // we set userId of the request to 0xf00 to be different from the one in the response
    AuthRequest memory auth = sismoConnect.exposed_buildAuth({
      authType: AuthType.GITHUB,
      userId: uint256(0xf00)
    }); // wrong userId
    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthTypeAndUserIdNotFound(uint8,uint256)",
        auth.authType,
        auth.userId
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: auth,
      signature: signature
    });
  }

  function test_RevertWith_AuthUserIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.GITHUB, userId: uint256(bytes32("wrong-id"))})
    });
    // we need to choose a different AuthType than AUthType.VAULT to be able to test if the userId error is thrown
    // we set userId of the request to 0xf00 to be different from the one in the response
    AuthRequest memory auth = sismoConnect.exposed_buildAuth({
      authType: AuthType.GITHUB,
      userId: uint256(0xf00)
    }); // wrong userId
    vm.expectRevert(abi.encodeWithSignature("AuthUserIdNotFound(uint256)", auth.userId));
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: auth,
      signature: signature
    });
  }

  function test_RevertWith_AuthTypeAndIsAnonNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT, isAnon: true})
    });
    AuthRequest memory auth = sismoConnect.exposed_buildAuth({
      authType: AuthType.GITHUB,
      isAnon: false
    });
    vm.expectRevert(
      abi.encodeWithSignature("AuthTypeAndIsAnonNotFound(uint8,bool)", auth.authType, auth.isAnon)
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: auth,
      signature: signature
    });
  }

  function test_RevertWith_AuthIsAnonNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT, isAnon: true})
    });
    AuthRequest memory auth = sismoConnect.exposed_buildAuth({
      authType: AuthType.VAULT,
      isAnon: false
    });
    vm.expectRevert(abi.encodeWithSignature("AuthIsAnonNotFound(bool)", auth.isAnon));
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: auth,
      signature: signature
    });
  }

  function test_RevertWith_AuthTypeNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withAuth({
      auth: AuthBuilder.build({authType: AuthType.VAULT})
    });
    AuthRequest memory auth = sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB});
    vm.expectRevert(abi.encodeWithSignature("AuthTypeNotFound(uint8)", auth.authType));
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      auth: auth,
      signature: signature
    });
  }

  function test_RevertWith_ClaimInRequestNotFoundInResponse() public {
    // we expect a revert since no proofs are provided in the response
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.build();
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimInRequestNotFoundInResponse(uint8,bytes16,bytes16,uint256,bytes)",
        claimRequest.claimType,
        claimRequest.groupId,
        claimRequest.groupTimestamp,
        claimRequest.value,
        claimRequest.extraData
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_ClaimGroupIdAndGroupTimestampNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: "wrong-id", groupTimestamp: bytes16("fake-timestamp")})
    });
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimGroupIdAndGroupTimestampNotFound(bytes16,bytes16)",
        claimRequest.groupId,
        claimRequest.groupTimestamp
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_ClaimTypeAndGroupTimestampNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({
        groupId: claimRequest.groupId,
        groupTimestamp: bytes16("fake-timestamp"),
        claimType: ClaimType.LTE
      })
    });
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeAndGroupTimestampNotFound(uint8,bytes16)",
        claimRequest.claimType,
        claimRequest.groupTimestamp
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_ClaimGroupTimestampNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({
        groupId: claimRequest.groupId,
        groupTimestamp: bytes16("wrong-timestamp")
      })
    });
    invalidResponse.proofs[0].claims[0].groupTimestamp = bytes16("fake-timestamp");
    vm.expectRevert(
      abi.encodeWithSignature("ClaimGroupTimestampNotFound(bytes16)", claimRequest.groupTimestamp)
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_ClaimTypeAndGroupIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: "wrong-id", claimType: ClaimType.LTE})
    });
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeAndGroupIdNotFound(uint8,bytes16)",
        claimRequest.claimType,
        claimRequest.groupId
      )
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_ClaimGroupIdNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: bytes16("wrong-group-id")})
    });
    vm.expectRevert(abi.encodeWithSignature("ClaimGroupIdNotFound(bytes16)", claimRequest.groupId));
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_RevertWith_ClaimTypeNotFound() public {
    SismoConnectResponse memory invalidResponse = DEFAULT_RESPONSE.withClaim({
      claim: ClaimBuilder.build({groupId: claimRequest.groupId, claimType: ClaimType.LTE})
    });
    vm.expectRevert(
      abi.encodeWithSignature("ClaimTypeNotFound(uint8)", uint8(claimRequest.claimType))
    );
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(invalidResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  function test_OneAuthOneClaimOneSignature() public {
    SismoConnectResponse memory validResponse = DEFAULT_RESPONSE
      .withAuth({
        auth: AuthBuilder.build({authType: AuthType.VAULT}),
        provingScheme: DEFAULT_PROVING_SCHEME
      })
      .withClaim({
        claim: ClaimBuilder.build({groupId: claimRequest.groupId}),
        provingScheme: DEFAULT_PROVING_SCHEME
      });
    sismoConnect.exposed_verify({
      responseBytes: abi.encode(validResponse),
      claim: claimRequest,
      signature: signature
    });
  }

  // helpers

  function emptyResponse() private pure returns (SismoConnectResponse memory) {
    return ResponseBuilder.empty();
  }
}
