// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import "src/libs/utils/Struct.sol";
import "src/libs/utils/DataRequestLib.sol";

contract ZkConnectTest is HydraS2BaseTest {
    function test_ZkConnect() public {
        bytes16 groupId = 0xe9ed316946d3d98dfcd829a53ec9822e;

        bytes memory zkResponseEncoded = hydraS2Proofs.getZkConnectResponse1AsBytes();
        ZkConnectResponse memory zkConnectResponse = abi.decode(zkResponseEncoded, (ZkConnectResponse));

        DataRequest memory dataRequest = DataRequestLib.build(groupId);

        ZkConnectVerifiedResult memory zkConnectVerifiedResult = zkConnectVerifier.verify(
            zkConnectResponse,
            dataRequest
        );

        console.log("zkConnectVerifiedResult.vaultId: %s", zkConnectVerifiedResult.vaultId);
    }
}
