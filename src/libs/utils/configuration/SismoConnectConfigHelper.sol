// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "stringutils/strings.sol";

struct SismoConnectConfig {
  bytes16 appId;
  VaultEnv vaultEnv;
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
    return
      _getSolidityConfig(
        root,
        configPath,
        "/lib/sismo-connect-onchain-verifier/typescript/configuration/compute-solidity-config.ts"
      );
  }

  function getConfig(
    string memory configPath,
    string memory computeSolidityFilePath
  ) internal returns (SismoConnectConfig memory) {
    string memory root = vm.projectRoot();
    _checkConfigFileExtension(configPath);
    return _getSolidityConfig(root, configPath, computeSolidityFilePath);
  }

  function _getSolidityConfig(
    string memory root,
    string memory configPath,
    string memory computeSolidityFilePath
  ) internal returns (SismoConnectConfig memory) {
    string memory stringifiedConfiguration = string(vm.ffi(_getConfigInputs(root, configPath)));

    string memory computeSolidityConfigPath = string.concat(root, computeSolidityFilePath);

    string[] memory inputs = new string[](4);
    inputs[0] = "npx";
    inputs[1] = "ts-node";
    inputs[2] = computeSolidityConfigPath;
    inputs[3] = stringifiedConfiguration;

    bytes memory config = vm.ffi(inputs);
    SismoConnectConfig memory sismoConnectConfig = abi.decode(config, (SismoConnectConfig));

    return sismoConnectConfig;
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
