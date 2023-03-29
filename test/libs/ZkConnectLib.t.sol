// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "../verifiers/hydra-s2/HydraS2BaseTest.t.sol";
import "src/libs/zk-connect/ZkConnectLib.sol";

contract ZkConnectLibTest is HydraS2BaseTest {
    ZkConnect zkConnect;
    ZkConnectRequestContent zkConnectRequestContent;
    bytes16 immutable appId = 0x112a692a2005259c25f6094161007967;

    ZkConnectResponse validZkConnectResponse;

    function setUp() public virtual override {
        super.setUp();
        zkConnect = new ZkConnect(appId);

        zkConnectRequestContent =
            ZkConnectRequestContentLib.buildClaimOnly({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});

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
        bytes memory zkResponseEncoded = hex"0000000000000000000000000000000000000000000000000000000000000020112a692a2005259c25f609416100796700000000000000000000000000000000b8e2054f8a912367e38a22ce773328ff000000000000000000000000000000007a6b2d636f6e6e6563742d76320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000180000000000000000000000000000000000000000000000000000000000000022068796472612d73322e310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000520e9ed316946d3d98dfcd829a53ec9822e000000000000000000000000000000006c617465737400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c0162fba0e2b357e6190d05471c08a4f4da6d0831bcefd8f7787d732d3156698d4119664dd2bfcc0d9b0d3513947fa1e20f9f73847c89ddc9f336476eea1106d03070eca2658f85ee8f9845aac26de7ad4ffccc78713f7dd2efb9024e0ef8750090c1f8c411c43ab85f6fe6cfbe53d1c5c3e90e322027bc12975fd96f02566cf1e12f139fd40095f34f8e0603cbe43efc2f03f32c638a94f8fb5f55f2252f48f0112bcbedd222aa50a515826acf4bda6fe381fa651f5b719c0510b81316bd4d1e02c65015a5fa1ae041d5682b490abdc864970b1c3178adbbd7d024ebbc9b06bae3002d7663bc44ebb4ac8567f0e6968dab8e4f479ffb45dc939d4b624392ee1e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa1d4a72bd1c1e4f9ab68c3c4c55afd3e582685a18b9ec09fc96136619d2513fe821a63725868405196971cad8f2e46ed111118a9869929d0f87c154c9c60d015f044f025508bb2ec3ad43852788f4f9f74c37ece5e1958c59b4558e7b098768510000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000028c8b31cfdb3021f44a90006d40ee6ff1d1080103a6704b0ba79f0493281599f00000000000000000000000000000000112a692a2005259c25f6094161007967000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
        assertEq(zkConnectVerifiedResult.verifiedAuths[0].userId, 0);
    }

    function test_ZkConnectLibWithOnlyOneAuth() public {
        zkConnectRequestContent = ZkConnectRequestContentLib.buildAuthOnly({authType: AuthType.ANON});

        bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse2());

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
