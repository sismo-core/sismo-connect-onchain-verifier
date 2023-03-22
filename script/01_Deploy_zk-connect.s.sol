// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {ZkConnectVerifier} from "src/ZkConnectVerifier.sol";

contract DeployZkConnect is Script {
    ZkConnectVerifier zkConnectVerifier;

    function run() external {
        vm.startBroadcast();

        zkConnectVerifier = new ZkConnectVerifier(0x112a692a2005259c25f6094161007967);

        console2.log("zkConnectVerifier Deployed:", address(zkConnectVerifier));

        vm.stopBroadcast();
    }
}
