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
        address destination = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;

        (DataRequest memory dataRequest) = createDataRequest(groupId, groupTimestamp, bytes16(keccak256(namespace)));
        zkConnectVerifier.verify(hydraS2Proofs.getZkConnectResponse1(), dataRequest, bytes16(keccak256(namespace)));
    }
}
