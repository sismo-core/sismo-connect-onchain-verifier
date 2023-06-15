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
  address immutable sismoAddressProviderV2 = 0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6;

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

    vm.etch(sismoAddressProviderV2, address(addressesProvider).code);

    IAddressesProvider(sismoAddressProviderV2).set(
      address(sismoConnectVerifier),
      string("sismoConnectVerifier-v1.1")
    );
    IAddressesProvider(sismoAddressProviderV2).set(
      address(authRequestBuilder),
      string("authRequestBuilder-v1.1")
    );
    IAddressesProvider(sismoAddressProviderV2).set(
      address(claimRequestBuilder),
      string("claimRequestBuilder-v1.1")
    );
    IAddressesProvider(sismoAddressProviderV2).set(
      address(signatureBuilder),
      string("signatureBuilder-v1.1")
    );
    IAddressesProvider(sismoAddressProviderV2).set(
      address(requestBuilder),
      string("requestBuilder-v1.1")
    );
  }
}
