// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "../verifiers/hydra-s2/HydraS2BaseTest.t.sol";
import {SismoConnect, RequestBuilder} from "src/libs/zk-connect/SismoConnectLib.sol";
import {ZKDropERC721} from "src/ZKDropERC721.sol";
import "src/libs/utils/Structs.sol";
import {SismoConnectHarness} from "test/harness/SismoConnectHarness.sol";
import {BaseDeploymentConfig} from "script/BaseConfig.sol";

contract SismoConnectLibTest is HydraS2BaseTest {
  SismoConnectHarness sismoConnect;
  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;
  bytes16 immutable appId = 0x11b1de449c6c4adb0b5775b3868b28b3;
  ClaimRequest claimRequest;
  AuthRequest authRequest;
  SignatureRequest signatureRequest;

  bytes16 immutable APP_ID_ZK_DROP = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 immutable ZK = 0xe9ed316946d3d98dfcd829a53ec9822e;
  ZKDropERC721 zkdrop;

  function setUp() public virtual override {
    super.setUp();
    sismoConnect = new SismoConnectHarness(appId);
    claimRequest = sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    authRequest = sismoConnect.exposed_buildAuth({authType: AuthType.VAULT});
    signatureRequest = sismoConnect.exposed_buildSignature({message: abi.encode(user)});

    zkdrop =
        new ZKDropERC721({appId: APP_ID_ZK_DROP, groupId: ZK, name: "ZKDrop test", symbol: "test", baseTokenURI: "https://test.com"});
        console.log("ZkDrop contract deployed at", address(zkdrop));
  }

  // Tests that should revert

  function test_RevertWith_EmptyMessageIfSismoConnectResponseIsEmpty() public {
    bytes memory responseBytes = hex"";
    // we just expect a revert with an empty responseBytes as far as the decoding will not be successful
    vm.expectRevert();
    sismoConnect.exposed_verify({responseBytes: responseBytes, claimRequest: claimRequest});
  }

  function test_RevertWith_VersionMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.version = bytes32("fake-version");
    bytes32 expectedVersion = bytes32("zk-connect-v2");
    vm.expectRevert(
      abi.encodeWithSignature(
        "VersionMismatch(bytes32,bytes32)",
        invalidSismoConnectResponse.version,
        expectedVersion
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest});
  }

  function test_RevertWith_AppIdMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.appId = 0x00000000000000000000000000000f00;
    vm.expectRevert(
      abi.encodeWithSignature(
        "AppIdMismatch(bytes16,bytes16)",
        invalidSismoConnectResponse.appId,
        hydraS2Proofs.getSismoConnectResponse1().appId
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest});
  }

  function test_RevertWith_NamespaceMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.namespace = bytes16(keccak256("fake-namespace"));
    vm.expectRevert(
      abi.encodeWithSignature(
        "NamespaceMismatch(bytes16,bytes16)",
        invalidSismoConnectResponse.namespace,
        hydraS2Proofs.getSismoConnectResponse1().namespace
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest});
  }

  function test_RevertWith_SignatureMessageMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    signatureRequest = sismoConnect.exposed_buildSignature({message: abi.encode("fake-signature")});
    vm.expectRevert(
      abi.encodeWithSignature(
        "SignatureMessageMismatch(bytes,bytes)",
        signatureRequest,
        hydraS2Proofs.getSismoConnectResponse1().signedMessage
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_AuthTypeMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse2();
    invalidSismoConnectResponse.proofs[0].auths[0].authType = AuthType.GITHUB;
    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthTypeMismatch(uint8,uint8)",
        uint8(invalidSismoConnectResponse.proofs[0].auths[0].authType),
        uint8(authRequest.authType)
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), authRequest: authRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_AuthAnonModeMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse2();
    invalidSismoConnectResponse.proofs[0].auths[0].isAnon = true;
    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthAnonModeMismatch(bool,bool)",
        invalidSismoConnectResponse.proofs[0].auths[0].isAnon,
        authRequest.isAnon
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), authRequest: authRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_AuthUserIdMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse2();
    invalidSismoConnectResponse.proofs[0].auths[0].userId = uint256(0xf00);
    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthUserIdMismatch(uint256,uint256)",
        invalidSismoConnectResponse.proofs[0].auths[0].userId,
        authRequest.userId
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), authRequest: authRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_AuthExtraDataMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse2();
    invalidSismoConnectResponse.proofs[0].auths[0].extraData = "fake-extra-data";
    vm.expectRevert(
      abi.encodeWithSignature(
        "AuthExtraDataMismatch(bytes,bytes)",
        invalidSismoConnectResponse.proofs[0].auths[0].extraData,
        authRequest.extraData
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), authRequest: authRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_ClaimTypeMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.proofs[0].claims[0].claimType = ClaimType.LTE;
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeMismatch(uint8,uint8)",
        uint8(invalidSismoConnectResponse.proofs[0].claims[0].claimType),
        uint8(claimRequest.claimType)
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_ClaimGroupIdMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.proofs[0].claims[0].groupId = 0xf0000000000000000000000000000000;
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimGroupIdMismatch(bytes16,bytes16)",
        invalidSismoConnectResponse.proofs[0].claims[0].groupId,
        claimRequest.groupId
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_ClaimGroupTimestampMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.proofs[0].claims[0].groupTimestamp = bytes16("fake-timestamp");
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimGroupTimestampMismatch(bytes16,bytes16)",
        invalidSismoConnectResponse.proofs[0].claims[0].groupTimestamp,
        claimRequest.groupTimestamp
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest, signatureRequest: signatureRequest});
  }

  function test_RevertWith_ClaimExtraDataMismatch() public {
    SismoConnectResponse memory invalidSismoConnectResponse = hydraS2Proofs.getSismoConnectResponse1();
    invalidSismoConnectResponse.proofs[0].claims[0].extraData = "fake-extra-data";
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimExtraDataMismatch(bytes,bytes)",
        invalidSismoConnectResponse.proofs[0].claims[0].extraData,
        claimRequest.extraData
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidSismoConnectResponse), claimRequest: claimRequest, signatureRequest: signatureRequest});
  }

  // tests that should pass without reverting

  function test_SismoConnectLibWithOnlyClaimAndMessage() public {
    bytes
      memory zkResponseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000540e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000002c0027e2ac77cccdd6a170377c53d01745477d8e220eea25899bd551a6d93a0287928d68511985e87a2c00e406a9689bfee26975214f087b257c2cfbb0d8422081b177b788f52df265b9a455441d16f1ba2775cbf46e065d956e21abda4170bb23223d275e7e1a049db15f41c5398f1e4cc41e89d4175134bdcc0695142a33c90ca2dd94b68dcb64b88911aa13f5a78e0aa0de1eb6d5b0e911960370d080108961b0df136e1229ccf8d38290fc8287999d2b9fbf0339c45abaacd489b8ff081773710f1270f26800a2b1e86ef3ed8eab23acaef9ec8115865a552f29791e6209060203b8deb2e7d4847bead3fcf406c83aef1a9b25c87676cc73e610f672f1e0c79000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa1900027a626c79673bcd47d69cf371248a6ba78feee2ec32c5e83b681af8433904f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc00000000000000000000000000000000000000000000000000000000000000000c5e3eb3996b56ed6e60c6c7823f4fa3e972a882bef34f6f35ed769bb60c35f90000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b3000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    //bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getSismoConnectResponse1());

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify({
      responseBytes: zkResponseEncoded,
      request: RequestBuilder.buildRequest({
        claimRequest: sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e}),
        signatureRequest: sismoConnect.exposed_buildSignature({message: abi.encode(user)}),
        appId: appId
      })
    });
    assertEq(verifiedResult.verifiedAuths[0].userId, 0);
  }

  function test_SismoConnectLibWithOnlyOneAuth() public {
    bytes
      memory zkResponseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000054000000000000000000000000000000000000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000002c00823e270146a83cf1ec74f9a2d48e083d1958d4b7fba9687295e5299520184d015cadbe4331a6a5d511921a5f33866c89dd6af364dfdc7182ddd748a3e3d5a8919c96d2ffe1b53ea06536618f396d8663f7b74f3e2d40eb535457672e6369f8a1c16a1ae759db8eeaa5c9a18cc794ddc93ce4667af00d4779641ff325eee9fac05155352b176c1c6eca01d2e2018890adae767afbad5974ea7950266083065512d953abb4f03b022c15609530a965cd2052c669e0edcdbf673f27a173b4f2ba62fd7a7ca858dd140b6192bf40e95c90f00f8b74e46aa69f2c504246168c76c6e050ffc10c6ca5ba1ae8474a84bd16bf8c051d713bc73b76343d6142d3a6e4e3b000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5e3eb3996b56ed6e60c6c7823f4fa3e972a882bef34f6f35ed769bb60c35f90000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    SismoConnectRequest memory request = RequestBuilder.buildRequest({
      authRequest: sismoConnect.exposed_buildAuth({authType: AuthType.VAULT}),
      signatureRequest: signatureRequest,
      appId: appId
    });

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify(
      zkResponseEncoded,
      request
    );
    assertTrue(verifiedResult.verifiedAuths[0].userId != 0);
  }

  function test_SismoConnectLibWithClaimAndAuth() public {
    bytes
      memory zkResponseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000540e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000002c0220cb37982b97aa8585899c5b6c384eb0723fb77c52939413d9b921568d95da82ba898042155cef1d8114bca8d8c1e35dcf8892083c31201aca5ca60970838e9230ae6beec34ad477e5da162a511e367d2d1a4ce41376cac9e919145f22606ab0d8d460e68b220d73dde985d084adeb87d5e83bc3120406dd18fbd5299ed76fc25bbf7d2743f87636f40c3fbfc737236aa43f4df88cf433393def95537ed6122182bcfefd46d137990184596dadaab29c7bad596b6d637cfcbbb85f52cc701ba01066e489ef6cc73745480fed74f14fda369f9c553e556294928062f96963b8418285da48d35a556fbd7aa0c70b4574c84b49ec66034502fa52d41facd9f56f4000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa1900027a626c79673bcd47d69cf371248a6ba78feee2ec32c5e83b681af8433904f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc00000000000000000000000000000000000000000000000000000000000000000c5e3eb3996b56ed6e60c6c7823f4fa3e972a882bef34f6f35ed769bb60c35f90000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b3000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    SismoConnectRequest memory request = RequestBuilder.buildRequest({
      claimRequest: sismoConnect.exposed_buildClaim({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e}),
      authRequest: sismoConnect.exposed_buildAuth({authType: AuthType.VAULT}),
      signatureRequest: signatureRequest,
      appId: appId
    });

    SismoConnectVerifiedResult memory verifiedResult = sismoConnect.exposed_verify(
      zkResponseEncoded,
      request
    );
    assertTrue(verifiedResult.verifiedAuths[0].userId != 0);
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

        bytes memory responseEncoded = hex"000000000000000000000000000000000000000000000000000000000000002011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000540e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000040200040600000201150028570102001e030e2600000000000000000000000000000000000000000000000000000000000002c00b0c5bbc3df72e9d6dd05ea034c31125f45417e29656c1495fc18ee6c51215e927ccfe87780fb12df4335bba03df6ccde3a3858d1c7db8dfe6648f7d4c81e6c10fbe0e3f0f2b041ac6646795449770a3c4feba26202d5e7bd2c89d7c364baae312ef73dcadf53e6408ff69d61dc0d43aa13975846a72734a0ad79e28b78f80f71fb35163c46e8cae1ec1e986f4e3b17628fcd71ca00d67e1e887b8b8408a0e6a20f4b2e3b9e1235940c258ba03cd804bdd70422f14b988c0bb3243c1b5ae0882012e75376642517e817b5f8e3863ff1966dd501c8721add9590f8e9e1f4ada1e13248f22a4fc19275664b1e09e6bd2bb8027d885b18d4191839db82ded0fc57400000000000000000000000000000000000000000000000000000000000000001e762fcc1e79cf55469b1e6ada7c8f80734bc7484f73098f3168be945a2c00842ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74126f694813ae22c129a784a369f10de1ede83dfde50edfaf341567e1ac5c2d5504f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc0000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b3000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        zkdrop.claimWithSismoConnect(responseEncoded, user);
    }

  // function test_SismoConnectLibTwoDataRequests() public {
  //     ClaimRequest memory claimRequest = ClaimRequestLib.build({
  //         groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
  //         groupTimestamp: bytes16("latest"),
  //         value: 2,
  //         claimType: ClaimType.EQ
  //     });

  //     AuthRequest memory authRequest = AuthRequestLib.build({authType: AuthType.EVM_ACCOUNT, isAnon: true});

  //     ClaimRequest memory claimRequestTwo =
  //         ClaimRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e, value: 1, claimType: ClaimType.GTE});

  //     AuthRequest memory authRequestTwo = AuthRequestLib.build({authType: AuthType.VAULT});

  //     DataRequest[] memory dataRequests = new DataRequest[](2);
  //     dataRequests[0] = DataRequestLib.build({claimRequest: claimRequest, authRequest: authRequest});
  //     dataRequests[1] = DataRequestLib.build({claimRequest: claimRequestTwo, authRequest: authRequestTwo});

  //     requestContent = SismoConnectRequestContentLib.build({dataRequests: dataRequests});

  //     bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getSismoConnectResponse1());

  //     SismoConnectVerifiedResult memory verifiedResult =
  //         sismoConnect.verify(zkResponseEncoded, requestContent);
  //     console.log("userId: %s", verifiedResult.verifiedAuths[0].userId);
  // }
}
