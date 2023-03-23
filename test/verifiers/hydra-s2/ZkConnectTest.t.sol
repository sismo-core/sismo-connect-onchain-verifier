// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import "src/libs/utils/Struct.sol";
import "src/libs/utils/ZkConnectRequestContentLib.sol";

contract ZkConnectTest is HydraS2BaseTest {
    function test_ZkConnect() public {
        bytes16 groupId = 0xe9ed316946d3d98dfcd829a53ec9822e;

        ZkConnectResponse memory zkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
        ZkConnectRequestContent memory zkConnectRequestContent = ZkConnectRequestContentLib.build(groupId);

        ZkConnectVerifiedResult memory zkConnectVerifiedResult =
            zkConnectVerifier.verify(zkConnectResponse, zkConnectRequestContent);

        console.log("userId: %s", zkConnectVerifiedResult.verifiedAuths[0].userId);
    }
}
