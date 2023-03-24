// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import "src/libs/zk-connect/ZkConnectLib.sol";

contract ZkConnectTest is HydraS2BaseTest {
    function test_ZkConnect() public {
        bytes16 groupId = 0xe9ed316946d3d98dfcd829a53ec9822e;

        ZkConnectResponse memory zkConnectResponse = hydraS2Proofs.getZkConnectResponse1();

        Claim memory claim = ClaimRequestLib.build({groupId: groupId});
        Auth memory auth;
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = DataRequest({claimRequest: claim, authRequest: auth, messageSignatureRequest: ""});

        ZkConnectRequestContent memory zkConnectRequestContent =
            ZkConnectRequestContentLib.build({dataRequests: dataRequests, operator: LogicalOperator.AND});

        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnectVerifier.verify(zkConnectResponse, zkConnectRequestContent);

        console.log("userId: %s", zkConnectVerifiedResult.verifiedAuths[0].userId);
    }
}
