// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/ZkConnectVerifier.sol";

contract DeployZkConnect is Script {
    ZkConnectVerifier zkConnectVerifier;

    function run() external {
        vm.startBroadcast();

        zkConnectVerifier = new ZkConnectVerifier();

        console2.log("zkConnectVerifier Deployed:", address(zkConnectVerifier));

        vm.stopBroadcast();
    }
}
