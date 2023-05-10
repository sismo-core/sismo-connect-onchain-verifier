// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/libs/utils/Fmt.sol";
import {HydraS2BaseTest} from "../verifiers/hydra-s2/HydraS2BaseTest.t.sol";
import {SismoConnect, RequestBuilder, ClaimRequestBuilder} from "src/libs/sismo-connect/SismoConnectLib.sol";
import {ZKDropERC721} from "src/ZKDropERC721.sol";
import "src/libs/utils/Structs.sol";
import {SismoConnectHarness} from "test/harness/SismoConnectHarness.sol";

import {AuthBuilder} from "src/libs/utils/AuthBuilder.sol";
import {ClaimBuilder} from "src/libs/utils/ClaimBuilder.sol";
import {ResponseBuilder, ResponseWithoutProofs} from "test/utils/ResponseBuilderLib.sol";
import {BaseDeploymentConfig} from "script/BaseConfig.sol";

// E2E tests for SismoConnect Solidity Library
// These tests are made with proofs generated from the Vault App
// These tests should not use any Verifier mocks

contract SismoConnectE2E is HydraS2BaseTest {
  using ResponseBuilder for SismoConnectResponse;
  using ResponseBuilder for ResponseWithoutProofs;

  SismoConnectHarness sismoConnect;
  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;

  // default values for tests
  bytes16 public DEFAULT_APP_ID = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 public DEFAULT_NAMESPACE = bytes16(keccak256("main"));
  bytes32 public DEFAULT_VERSION = bytes32("sismo-connect-v1");
  bytes public DEFAULT_SIGNED_MESSAGE = abi.encode(user);

  ResponseWithoutProofs public DEFAULT_RESPONSE = ResponseBuilder.emptyResponseWithoutProofs().withAppId(DEFAULT_APP_ID)
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
    sismoConnect = new SismoConnectHarness(DEFAULT_APP_ID);
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

  function test_SismoConnectLibWithOnlyClaimAndMessage() public {
    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithOneClaimAndSignature(
      commitmentMapperRegistry
    );

    sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: requestBuilder.build({
        claim: sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e}),
        signature: sismoConnect.exposed_buildSignature({message: abi.encode(user)}),
        appId: DEFAULT_APP_ID
      })
    });
  }

  function test_SismoConnectLibWithTwoClaimsAndMessage() public {
    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithTwoClaimsAndSignature(
      commitmentMapperRegistry
    );

    ClaimRequest[] memory claims = new ClaimRequest[](2);
    claims[0] = sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = sismoConnect.exposed_buildClaim({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});

    sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: requestBuilder.build({
        claims: claims,
        signature: sismoConnect.exposed_buildSignature({message: abi.encode(user)}),
        appId: DEFAULT_APP_ID
      })
    });
  }

  function test_SismoConnectLibWithOnlyOneAuth() public {
    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithOnlyOneAuthAndMessage(
      commitmentMapperRegistry
    );

    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.VAULT}),
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify(
      responseEncoded,
      request
    );
    assertTrue(verifiedResult.auths[0].userId != 0);
  }

  function test_SismoConnectLibWithClaimAndAuth() public {
    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithOneClaimOneAuthAndOneMessage(
      commitmentMapperRegistry
    );
    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.VAULT}),
      claim: sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e}),
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify(
      responseEncoded,
      request
    );
    assertTrue(verifiedResult.auths[0].userId != 0);
  }

  function test_ClaimAndAuthWithSignedMessageZKDROP() public {
    // address that reverts if not modulo SNARK_FIELD after hashing the signedMessage for the circuit
    // should keep this address for testing purposes
    user = 0x040200040600000201150028570102001e030E26;

    // update EdDSA public key for proof made in dev.beta environment
    uint256[2] memory devBetaCommitmentMapperPubKey = [
      0x2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f0256,
      0x30423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74
    ];
    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(devBetaCommitmentMapperPubKey);

    // proof of membership for user in group 0xe9ed316946d3d98dfcd829a53ec9822e
    // vault ownership
    // signedMessage: 0x040200040600000201150028570102001e030E26
    bytes
      memory responseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000040200040600000201150028570102001e030e2600000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000004c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c01de3d2c977a8e58feff29cfddb6fd4a0861b23bb6d90219eff6f5edcb63a0d9d14d63301976c6a94d036c6328523b3f5f8faa2a6e225f5c224e2dd30f3d3d8671555862d73608974669dc344eeccec6930cb0345b242a6522c6cc3978ed8839009b14760df538a68d0fe24ecd941326443efe56d761c6bae0ebedfef09e25e3f26df58f0424072e2c6eaa685e76718c4e617a178b39dbbb6987812fb611849311be52ebc5a77d2f7e5563002e6ce7e86192bdfa2833cbd604561932ddf5908cd1c23c46ef0bd16a497785d6f96d233ac42b41926398ce7a15ec5147353bbe2aa058dd7b01cfcdd2530e1d7e9367fb3c9cfadeb113108dd4ea4369a56004abc2000000000000000000000000000000000000000000000000000000000000000001e762fcc1e79cf55469b1e6ada7c8f80734bc7484f73098f3168be945a2c00842ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db7408642c70876b81cb23b3ec10faeb472fb0d463430bcb4ef2a2715e5a0fe67d3d04f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000018202c14c40a8bc84b8fc8748836190f53fc45c66ad969c7bfa2a91afdd1ad8d01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000118202c14c40a8bc84b8fc8748836190f53fc45c66ad969c7bfa2a91afdd1ad8d00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c00d327a8926174279f06e4bd83beb64c354272a79d80823e0d37c51132e60dd6e119515b68f7aba56affd8a9f63504c1e25acda034937ce14b0df88bf6d17df5f0201a6313901681a0585bba3bfdfb9300ebf40533b123cb09eb3e45d88b60b161d9a945c14b58f3e5fba86124715f308d1abf7f30ee80c8b4951a6cb214fd97906df330a55ea17f4eb46a9e6a49b3c0b2be1e84eb79a9781804026a8e058141f08da0cc486a49b069210b781cee8110563f6b6db9816af0ea93750004552ac98169aaee924168467c7adb297354463f16acc2a9839fc1b9288b42062650a29fd2a38703e0837cb8bb62b535d55b295c1da1c5e1f5469d150202929e8793d903b00000000000000000000000000000000000000000000000000000000000000001e762fcc1e79cf55469b1e6ada7c8f80734bc7484f73098f3168be945a2c00842ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db7400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018202c14c40a8bc84b8fc8748836190f53fc45c66ad969c7bfa2a91afdd1ad8d01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    zkdrop.claimWithSismoConnect(responseEncoded, user);
  }

  function test_TwoClaimsOneVaultAuthWithSignature() public {
    ClaimRequest[] memory claims = new ClaimRequest[](2);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = claimRequestBuilder.build({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});

    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = authRequestBuilder.build({authType: AuthType.VAULT});

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithTwoClaimsOneAuthAndOneSignature(
      commitmentMapperRegistry
    );

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_ThreeClaimsOneVaultAuthWithSignatureOneClaimOptional() public {
    ClaimRequest[] memory claims = new ClaimRequest[](3);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = claimRequestBuilder.build({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});
    claims[2] = claimRequestBuilder.build({
      groupId: 0x42c768bb8ae79e4c5c05d3b51a4ec74a,
      isOptional: true,
      isSelectableByUser: false
    });

    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = authRequestBuilder.build({authType: AuthType.VAULT});

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithTwoClaimsOneAuthAndOneSignature(
      commitmentMapperRegistry
    );

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_ThreeClaimsOneVaultAuthOneTwitterAuthWithSignatureOneClaimOptionalAndTwitterAuthOptional()
    public
  {
    ClaimRequest[] memory claims = new ClaimRequest[](3);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    claims[1] = claimRequestBuilder.build({groupId: 0x02d241fdb9d4330c564ffc0a36af05f6});
    claims[2] = claimRequestBuilder.build({
      groupId: 0x42c768bb8ae79e4c5c05d3b51a4ec74a,
      isOptional: true,
      isSelectableByUser: false
    });

    AuthRequest[] memory auths = new AuthRequest[](2);
    auths[0] = authRequestBuilder.build({authType: AuthType.VAULT});
    auths[1] = authRequestBuilder.build({authType: AuthType.TWITTER, isOptional: true, isSelectableByUser: true});

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    (, bytes memory responseEncoded) = hydraS2Proofs.getResponseWithTwoClaimsOneAuthAndOneSignature(
      commitmentMapperRegistry
    );

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_OneClaimOneOptionalTwitterAuthOneGithubAuthWithSignature() public {
    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(
      hydraS2Proofs.getEdDSAPubKeyDevBeta()
    );

    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claimRequestBuilder.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});

    AuthRequest[] memory auths = new AuthRequest[](2);
    auths[0] = authRequestBuilder.build({authType: AuthType.GITHUB});
    auths[1] = authRequestBuilder.build({authType: AuthType.TWITTER, isOptional: true, isSelectableByUser: true});

    SismoConnectRequest memory request = requestBuilder.build({
      claims: claims,
      auths: auths,
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    bytes
      memory responseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007369736d6f2d636f6e6e6563742d76310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000c068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e000000000000000000000000000000000000000000000000000000000000004c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c01271cb29ecdb133e3049fa43d6d9cf82322a5345d46e795359b23b066aae2017262e27684af386d005c032178f86c98a0e82cfe5bb59357740c99b1bd5150c492306ae8aaef8ffdc900f11b1cc1294db4686d8b4eb239cd34a45f2d2a6d47f4c2f680cdf3a0f75026968c4b66a38668d414e4ef64537d3ef499721ac0e3a7df01ee11a16c3a5a70175c0b42af3b85137947a4b283ee71c21a3959fe1c6d7b7430f4bb30ab991e54be08735ff420a33277ff45a75e9382c4b84e50be8150ae2651d62ab550f4eabfde37469a2feb7398792d165deae9b7bbdca77402c6d4f9eb20f3dad4c257747b8c347db4532bd9e028f047819257193bcfb91b18f78d80c39000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db7411f7fde533960ea368ab0af29e6690687bb97ff54af42f77a071adf0e5a0ef7b04f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000018202c14c40a8bc84b8fc8748836190f53fc45c66ad969c7bfa2a91afdd1ad8d01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001a068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c000000000000000000000000000000000000000000000000000000000000004a000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000100100000000000000000000000000009999037000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c010be2d095fccc5b01a0ce59148e124612e191bf60665f628c44fc1b907a415b02a0b38102fba1599be3c67487cce116a75741ae4561e2d0aefbc9714a135135d22bd55eb67b9d8fabd19dc185a50f597253d14cb0b2c3f58cf86a3e5fa81c8b507f633eff6d94aac4266206a59d4eb209ccd0a7644e5d874a97e8c530ac6a24c246344ec8446eee1622610ae432b533b528a0e6cdf02c05b7bf66c7b2b4f23021021c20bfce161a8efd0f62d6e4db3f936356d195ebfcc5ea15803d9688443cd0582917bffa2d4fb86b193e00a50a9f3be480f275d8cb47546578e0bfe16ade82b701f9e20e32e916849a04996958db5ef2e622e58707dfbc93c67c88265fc23000000000000000000000000100100000000000000000000000000009999037009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db7400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018202c14c40a8bc84b8fc8748836190f53fc45c66ad969c7bfa2a91afdd1ad8d01935d4d418952220ae0332606f61de2894d8b84c3076e6097ef3746a1ba04a5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000";

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: responseEncoded,
      request: request
    });
    console.log("Claims in Verified result: %s", verifiedResult.claims.length);
  }

  function test_GitHubAuth() public {
    (, bytes memory encodedResponse) = hydraS2Proofs.getResponseWithGitHubAuth(
      commitmentMapperRegistry
    );

    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB}),
      signature: signature,
      appId: DEFAULT_APP_ID
    });

    sismoConnect.exposed_verify({responseBytes: encodedResponse, request: request});
  }

  function test_GitHubAuthWithoutSignature() public {
    (, bytes memory encodedResponse) = hydraS2Proofs.getResponseWithGitHubAuthWithoutSignature(
      commitmentMapperRegistry
    );

    SismoConnectRequest memory request = requestBuilder.build({
      auth: sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB}),
      appId: DEFAULT_APP_ID
    });

    sismoConnect.exposed_verify({responseBytes: encodedResponse, request: request});
  }
  
  // helpers

  function emptyResponse() private pure returns (SismoConnectResponse memory) {
    return ResponseBuilder.empty();
  }
}
