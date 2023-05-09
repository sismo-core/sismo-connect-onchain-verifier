// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {AddressesProviderMock} from "test/mocks/AddressesProviderMock.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";
import {SismoConnectVerifier} from "src/SismoConnectVerifier.sol";
import {SismoConnect} from "src/libs/SismoLib.sol";
import {RequestBuilder, AuthRequestBuilder, ClaimRequestBuilder, SignatureBuilder} from "src/libs/sismo-connect/SismoConnectLib.sol";

contract BaseTest is Test {
  address immutable user1 = vm.addr(1);
  address immutable user2 = vm.addr(2);
  address immutable owner = vm.addr(3);
  address immutable sismoAddressProvider = 0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05;

  AddressesProviderMock addressesProvider;
  SismoConnectVerifier sismoConnectVerifier;

  // external libraries
  AuthRequestBuilder authRequestBuilder;
  ClaimRequestBuilder claimRequestBuilder;
  SignatureBuilder signatureBuilder;
  RequestBuilder requestBuilder;

  function setUp() public virtual {
    addressesProvider = new AddressesProviderMock();
    sismoConnectVerifier = new SismoConnectVerifier(owner);

    // external libraries
    authRequestBuilder = new AuthRequestBuilder();
    claimRequestBuilder = new ClaimRequestBuilder();
    signatureBuilder = new SignatureBuilder();
    requestBuilder = new RequestBuilder();

    vm.etch(sismoAddressProvider, address(addressesProvider).code);

    IAddressesProvider(sismoAddressProvider).set(
      address(sismoConnectVerifier),
      string("sismoConnectVerifier-v1")
    );
    IAddressesProvider(sismoAddressProvider).set(
      address(authRequestBuilder),
      string("authRequestBuilder-v1")
    );
    IAddressesProvider(sismoAddressProvider).set(
      address(claimRequestBuilder),
      string("claimRequestBuilder-v1")
    );
    IAddressesProvider(sismoAddressProvider).set(
      address(signatureBuilder),
      string("signatureBuilder-v1")
    );
    IAddressesProvider(sismoAddressProvider).set(
      address(requestBuilder),
      string("requestBuilder-v1")
    );
  }
}
