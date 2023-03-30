// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "../verifiers/hydra-s2/HydraS2BaseTest.t.sol";
import "src/libs/zk-connect/ZkConnectLib.sol";

contract ZkConnectLibTest is HydraS2BaseTest {
    ZkConnect zkConnect;
    ZkConnectRequestContent zkConnectRequestContent;
    bytes16 immutable appId = 0xf68985adfc209fafebfb1a956913e7fa;

    ZkConnectResponse validZkConnectResponse;

    function setUp() public virtual override {
        super.setUp();
        zkConnect = new ZkConnect(appId);

        Claim memory claimRequest = ClaimRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});

        address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;
        console.log("user: %s", user);
        console.logBytes(abi.encodePacked(user));

        zkConnectRequestContent =
            ZkConnectRequestContentLib.build({claimRequest: claimRequest, messageSignatureRequest: abi.encodePacked(user)});

        validZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    }

    function test_RevertWith_InvalidZkConnectResponse() public {
        bytes memory zkConnectResponseEncoded = hex"";
        vm.expectRevert(abi.encodeWithSignature("ZkConnectResponseIsEmpty()"));
        zkConnect.verify(zkConnectResponseEncoded, zkConnectRequestContent);
    }

    function test_RevertWith_InvalidZkConnectVersion() public {
        ZkConnectResponse memory invalidZkConnectResponse = validZkConnectResponse;
        invalidZkConnectResponse.version = bytes32("fake-version");
        vm.expectRevert(
            abi.encodeWithSignature(
                "InvalidZkConnectVersion(bytes32,bytes32)",
                invalidZkConnectResponse.version,
                zkConnect.getZkConnectVersion()
            )
        );
        zkConnect.verify(abi.encode(invalidZkConnectResponse), zkConnectRequestContent);
    }

    function test_RevertWith_InvalidZkConnectAppId() public {
        ZkConnectResponse memory invalidZkConnectResponse = validZkConnectResponse;
        invalidZkConnectResponse.appId = 0x00000000000000000000000000000f00;
        vm.expectRevert(
            abi.encodeWithSignature(
                "AppIdMismatch(bytes16,bytes16)", invalidZkConnectResponse.appId, validZkConnectResponse.appId
            )
        );
        zkConnect.verify(abi.encode(invalidZkConnectResponse), zkConnectRequestContent);
    }

    function test_RevertWith_InvalidNamespace() public {
        ZkConnectResponse memory invalidZkConnectResponse = validZkConnectResponse;
        invalidZkConnectResponse.namespace = bytes16(keccak256("fake-namespace"));
        vm.expectRevert(
            abi.encodeWithSignature(
                "NamespaceMismatch(bytes16,bytes16)",
                invalidZkConnectResponse.namespace,
                validZkConnectResponse.namespace
            )
        );
        zkConnect.verify(abi.encode(invalidZkConnectResponse), zkConnectRequestContent);
    }

    function test_RevertWith_UnequalProofsAndStatementRequestsLength() public {
        ZkConnectResponse memory invalidZkConnectResponse = validZkConnectResponse;
        invalidZkConnectResponse.proofs = new ZkConnectProof[](0);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ProofsAndDataRequestsAreUnequalInLength(uint256,uint256)",
                invalidZkConnectResponse.proofs.length,
                zkConnectRequestContent.dataRequests.length
            )
        );
        zkConnect.verify(abi.encode(invalidZkConnectResponse), zkConnectRequestContent);
    }

    function test_ZkConnectLibWithOnlyClaim() public {
        bytes memory zkResponseEncoded = hex"0000000000000000000000000000000000000000000000000000000000000020f68985adfc209fafebfb1a956913e7fa00000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002600000000000000000000000000000000000000000000000000000000000000540e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000002c0220ec2678460ece47a0a7d64eb05529881d9056f89965157de6043b913fa1ac817984c470e3c6c06146d7adbc299fc7e7b1828813afe1b91986f1219c5c424332ec6e6957db805a319019526e7bc7ca34b3c069f153b2f6f7ede5bb42a2181ac159a93759a5eb820ebaa8b0aa1bc3da1e3ca3b79701f13c723741d78a80c48d403867770c85a774446e110f39ef9154f9c79aa98d4ddb499f31fd643393498992d84dbedbfe25599fc7c8a8ca74f79e251eab78eb803cf2d4792587b560ac71111e5eb59ebf229fdad2d142d0929dc6add9e5e110fc2b6da0b25d3eb2a14b031293e68a737ad08e26f526ec522504300995058df6d3c8c4644500f006b66807e000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa2db629f18dc904ef403dd497303d02e8f0b4059786899373d734f3c6389442ec0edcebd3d30d0a9e5ba1fbaae8057165de46b61ddc5e81b1701dbf79995d77e51f853dbff160e80ee19ed2e3ae534c228873736d841ecec2339564c28a31db2d0000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000015fb9d7ca9f692b09201b5277a41f295ce6530786b4ce23051ef72c53252097300000000000000000000000000000000f68985adfc209fafebfb1a956913e7fa000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        //bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse1());

        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
        assertEq(zkConnectVerifiedResult.verifiedAuths[0].userId, 0);
    }

    function test_ZkConnectLibWithOnlyOneAuth() public {
        bytes memory zkResponseEncoded = hex"0000000000000000000000000000000000000000000000000000000000000020f68985adfc209fafebfb1a956913e7fa00000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e31000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000260000000000000000000000000000000000000000000000000000000000000054000000000000000000000000000000000000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000007def1d6d28d6bda49e69fa89ad75d160becba3ae00000000000000000000000000000000000000000000000000000000000002c0034ff20f66af815e74ca44f6d786ab7098ed1213e6d96a5046f3ae28f5d55ca421b38959e4670b4099bb19facb90087c27eb58272a4d1eae3dc7867714dc2c29186ea84666eb0b287ebca3d4b73890d6ba980330f435811b43bf63a9cbf554bf2c121f259fcc92134f706a6acefe1977f095ef853d4ab2375c64aca7d53227972604e5f84a3b2cc82c792ee08d57005ce19561cff54bb3ed82a96c5307c9759b1329f63f651aa5dd105f5116c820fd0d2709720c148e2d8f2af677154a433b401b0ed9b221c6c15f2b4de9c7de5cd157c1145de1ad98e4d90cd914cec36790f2215663326b80f27edcd3613684a46654b73145008a1637dab70205788bfa45bc000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015fb9d7ca9f692b09201b5277a41f295ce6530786b4ce23051ef72c53252097300000000000000000000000000000000f68985adfc209fafebfb1a956913e7fa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        zkConnectRequestContent = ZkConnectRequestContentLib.buildAuth({authType: AuthType.ANON});

        //bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse2());

        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
        assertTrue(zkConnectVerifiedResult.verifiedAuths[0].userId != 0);
    }
    // function test_ZkConnectLibWithClaimAndAuth() public {
    //     bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse1());

    //     Claim memory claimRequest = ClaimRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
    //     Auth memory authRequest = AuthRequestLib.build({authType: AuthType.ANON});
    //     zkConnectRequestContent =
    //         ZkConnectRequestContentLib.build({claimRequest: claimRequest, authRequest: authRequest});

    //     ZkConnectVerifiedResult memory zkConnectVerifiedResult =
    //         zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
    //     assertTrue(zkConnectVerifiedResult.verifiedAuths[0].userId != 0);
    //     console.log("userId: %s", zkConnectVerifiedResult.verifiedAuths[0].userId);
    // }

    // function test_ZkConnectLibTwoDataRequests() public {
    //     Claim memory claimRequest = ClaimRequestLib.build({
    //         groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
    //         groupTimestamp: bytes16("latest"),
    //         value: 2,
    //         claimType: ClaimType.EQ
    //     });

    //     Auth memory authRequest = AuthRequestLib.build({authType: AuthType.EVM_ACCOUNT, anonMode: true});

    //     Claim memory claimRequestTwo =
    //         ClaimRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e, value: 1, claimType: ClaimType.GTE});

    //     Auth memory authRequestTwo = AuthRequestLib.build({authType: AuthType.ANON});

    //     DataRequest[] memory dataRequests = new DataRequest[](2);
    //     dataRequests[0] = DataRequestLib.build({claimRequest: claimRequest, authRequest: authRequest});
    //     dataRequests[1] = DataRequestLib.build({claimRequest: claimRequestTwo, authRequest: authRequestTwo});

    //     zkConnectRequestContent = ZkConnectRequestContentLib.build({dataRequests: dataRequests});

    //     bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse1());

    //     ZkConnectVerifiedResult memory zkConnectVerifiedResult =
    //         zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
    //     console.log("userId: %s", zkConnectVerifiedResult.verifiedAuths[0].userId);
    // }
}
