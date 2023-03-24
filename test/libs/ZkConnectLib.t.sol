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

        Claim memory claim = ClaimRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});
        Auth memory auth;
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = DataRequest({claimRequest: claim, authRequest: auth, messageSignatureRequest: ""});
        zkConnectRequestContent =
            ZkConnectRequestContentLib.build({dataRequests: dataRequests, operator: LogicalOperator.AND});

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
        bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse1());
        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
        console.log("userId: %s", zkConnectVerifiedResult.verifiedAuths[0].userId);
    }

    function test_ZkConnectLibWithOnlyOneAuth() public {
        Claim memory claim;
        Auth memory auth = AuthRequestLib.build({authType: AuthType.ANON});
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = DataRequest({claimRequest: claim, authRequest: auth, messageSignatureRequest: ""});

        zkConnectRequestContent =
            ZkConnectRequestContentLib.build({dataRequests: dataRequests, operator: LogicalOperator.AND});

        bytes memory zkResponseEncoded = abi.encode(hydraS2Proofs.getZkConnectResponse2());
        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnect.verify(zkResponseEncoded, zkConnectRequestContent);
        console.log("userId: %s", zkConnectVerifiedResult.verifiedAuths[0].userId);
    }
}
