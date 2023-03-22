// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "../verifiers/hydra-s2/HydraS2BaseTest.t.sol";
import "src/libs/zk-connect/ZkConnectLib.sol";

contract ZkConnectTest is HydraS2BaseTest {
    DataRequest dataRequest = DataRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});

    bytes16 immutable appId = 0x112a692a2005259c25f6094161007967;

    function test_ZkConnectLib() public {
        ZkConnect zkConnect = new ZkConnect(appId, address(addressesProvider));

        bytes memory zkResponseEncoded = hydraS2Proofs.getZkConnectResponse1();
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = zkConnect.verify(zkResponseEncoded, dataRequest);

        console.log("zkConnectVerifiedResult.vaultId: %s", zkConnectVerifiedResult.vaultId);
    }
}
