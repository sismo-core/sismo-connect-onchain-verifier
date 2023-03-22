// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AddressesProviderMock} from "test/mocks/AddressesProviderMock.sol";
import {ZkConnectVerifier} from "src/ZkConnectVerifier.sol";
import {ZkConnect} from "src/libs/SismoLib.sol";

contract BaseTest is Test {
    address immutable user1 = vm.addr(1);
    address immutable user2 = vm.addr(2);
    address immutable owner = vm.addr(3);

    AddressesProviderMock addressesProvider;
    ZkConnectVerifier zkConnectVerifier;
    ZkConnect zkConnect;

    bytes16 immutable appId = 0x112a692a2005259c25f6094161007967;

    function setUp() public virtual {
        addressesProvider = new AddressesProviderMock();
        zkConnectVerifier = new ZkConnectVerifier();
        addressesProvider.set(address(zkConnectVerifier),string("zkConnectVerifier"));
        
        zkConnect = new ZkConnect(appId, address(addressesProvider));
    }
}