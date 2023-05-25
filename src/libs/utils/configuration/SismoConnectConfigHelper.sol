// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "stringutils/strings.sol";

struct SismoConnectConfig {
  bytes16 appId;
  bool devMode;
  uint256 registryTreeRoot;
  DevGroup[] devGroups;
}

struct DevGroup {
  bytes16 groupId;
}

enum VaultEnv {
  PROD,
  DEV
}

contract SismoConnectConfigHelper is TestBase, ScriptBase {
  using strings for *;

  function getConfig(string memory configPath) internal returns (SismoConnectConfig memory) {
    string memory root = vm.projectRoot();

    _checkConfigFileExtension(configPath);

    string[] memory configInputs = _getConfigInputs(root, configPath);

    string memory computeConfigPath = string.concat(
      root,
      "/typescript/configuration/compute-solidity-config.ts"
    );
    string[] memory inputs = new string[](4);
    inputs[0] = "npx";
    inputs[1] = "ts-node";
    inputs[2] = computeConfigPath;
    inputs[3] = string(vm.ffi(configInputs));

    bytes memory res = vm.ffi(inputs);
    SismoConnectConfig memory config = abi.decode(res, (SismoConnectConfig));

    // logs for debugging
    console2.log("appId");
    console2.logBytes16(config.appId);
    console2.log("devMode");
    console2.logBool(config.devMode);
    console2.log("registryTreeRoot");
    console2.logUint(config.registryTreeRoot);
    console2.log("devGroups.length");
    console2.logUint(config.devGroups.length);
    return config;
  }

  function _getConfigInputs(
    string memory root,
    string memory configPath
  ) internal pure returns (string[] memory) {
    string[] memory inputs = new string[](3);
    inputs[0] = "npx";
    inputs[1] = "ts-node";
    inputs[2] = string.concat(root, configPath);
    return inputs;
  }

  function _checkConfigFileExtension(string memory configPath) internal pure {
    strings.slice memory configPathAsSlice = configPath.toSlice();
    bool isConfigPathTypescript = configPathAsSlice.endsWith(".ts".toSlice());
    bool isConfigPathJavascript = configPathAsSlice.endsWith(".js".toSlice());
    require(
      isConfigPathTypescript || isConfigPathJavascript,
      "Configuration file must be a .ts or .js file"
    );
  }
}
