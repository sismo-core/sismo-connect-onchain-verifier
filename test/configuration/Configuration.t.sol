// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {SismoConnectConfigHelper, SismoConnectConfig} from "src/libs/utils/configuration/SismoConnectConfigHelper.sol";

contract ConfigurationTest is TestBase, SismoConnectConfigHelper {
  function test_readConfiguration() public {
    SismoConnectConfig memory config = getConfig(
      "/test/configuration/test-files/sismo-connect-config.js"
    );
  }
}
