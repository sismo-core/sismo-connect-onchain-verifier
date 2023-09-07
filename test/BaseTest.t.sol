// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AddressesProviderMock} from "test/mocks/AddressesProviderMock.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";
import {SismoConnectVerifier} from "src/SismoConnectVerifier.sol";

contract BaseTest is Test {
  address immutable user1 = vm.addr(1);
  address immutable user2 = vm.addr(2);
  address immutable owner = vm.addr(3);
  address immutable sismoAddressProviderV2 = 0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6;

  AddressesProviderMock addressesProvider;
  SismoConnectVerifier sismoConnectVerifier;

  function setUp() public virtual {
    addressesProvider = new AddressesProviderMock();
    sismoConnectVerifier = new SismoConnectVerifier(owner);

    vm.etch(sismoAddressProviderV2, address(addressesProvider).code);

    IAddressesProvider(sismoAddressProviderV2).set(
      address(sismoConnectVerifier),
      string("sismoConnectVerifier-v1.2")
    );
  }
}
