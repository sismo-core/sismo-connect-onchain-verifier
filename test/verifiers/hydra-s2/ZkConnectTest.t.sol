// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import "src/libs/utils/Struct.sol";

contract ZkConnectTest is HydraS2BaseTest {
    function test_ZkConnect() public {
        bytes16 groupId = 0xe9ed316946d3d98dfcd829a53ec9822e;
        bytes16 groupTimestamp = bytes16('latest');
        bytes memory namespace = bytes("main");

        bytes memory zkResponseEncoded = hydraS2Proofs.getZkConnectResponse1();

        (DataRequest memory dataRequest) = zkConnect.createDataRequest(groupId, groupTimestamp, bytes16(keccak256(namespace)));
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = zkConnect.verify(zkResponseEncoded, dataRequest, bytes16(keccak256(namespace)));
        console.log("zkConnectVerifiedResult.vaultId: %s", zkConnectVerifiedResult.vaultId);
    }
}
