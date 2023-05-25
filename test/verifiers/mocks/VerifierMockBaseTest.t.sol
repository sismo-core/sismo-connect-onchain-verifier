// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {BaseTest} from "test/BaseTest.t.sol";
import {VerifierMock} from "test/mocks/VerifierMock.sol";

contract VerifierMockBaseTest is BaseTest {
  VerifierMock verifierMock;

  function setUp() public virtual override {
    super.setUp();

    verifierMock = new VerifierMock();

    vm.startPrank(owner);
    sismoConnectVerifier.registerVerifier(verifierMock.VERSION(), address(verifierMock));
    vm.stopPrank();
  }
}
