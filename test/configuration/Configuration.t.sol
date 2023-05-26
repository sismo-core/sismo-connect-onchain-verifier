// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {SismoConnectConfigHelper, SismoConnectConfig, VaultEnv} from "src/libs/utils/configuration/SismoConnectConfigHelper.sol";

contract ConfigurationTest is Test, SismoConnectConfigHelper {
  function test_readConfigurationTSFile() public {
    SismoConnectConfig memory config = getConfig({
      configPath: "/test/configuration/test-files/sismo-connect-config.ts",
      computeSolidityFilePath: "/typescript/configuration/compute-solidity-config.ts"
    });

    _checkDevVaultConfiguration(config);
  }

  function test_readConfigurationJSFile() public {
    SismoConnectConfig memory config = getConfig({
      configPath: "/test/configuration/test-files/sismo-connect-config.js",
      computeSolidityFilePath: "/typescript/configuration/compute-solidity-config.ts"
    });

    _checkDevVaultConfiguration(config);
  }

  function _checkDevVaultConfiguration(SismoConnectConfig memory config) internal {
    assertEq32(config.appId, bytes16(0xf4977993e52606cfd67b7a1cde717069));
    assertTrue(config.vaultEnv == VaultEnv.DEV);
  }
}
