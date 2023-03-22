// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {ZkConnectVerifier} from "src/ZkConnectVerifier.sol";

contract BaseTest is Test {
    address immutable user1 = vm.addr(1);
    address immutable user2 = vm.addr(2);
    address immutable owner = vm.addr(3);
    ZkConnectVerifier zkConnectVerifier;

    function setUp() public virtual {
        bytes16 appId = 0x112a692a2005259c25f6094161007967;
        zkConnectVerifier = new ZkConnectVerifier(appId);
    }
}
