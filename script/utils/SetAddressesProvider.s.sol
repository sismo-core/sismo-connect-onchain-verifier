// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";
import {BaseDeploymentConfig, DeploymentConfig} from "script/BaseConfig.sol";

contract SetAddressesProvider is Script, BaseDeploymentConfig {
  function run() external {
    string memory chainName = vm.envString("CHAIN_NAME");
    _setDeploymentConfig({chainName: chainName, checkIfEmpty: false});

    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Sender:", msg.sender);

    vm.startBroadcast();

    _setAddress(config.sismoConnectVerifier, string("sismoConnectVerifier-v1.2"));
    _setAddress(config.hydraS3Verifier, string("hydraS3Verifier"));
    _setAddress(config.availableRootsRegistry, string("sismoConnectAvailableRootsRegistry"));
    _setAddress(config.commitmentMapperRegistry, string("sismoConnectCommitmentMapperRegistry"));

    // external libraries

    _setAddress(config.authRequestBuilder, string("authRequestBuilder-v1.1"));
    _setAddress(config.claimRequestBuilder, string("claimRequestBuilder-v1.1"));
    _setAddress(config.signatureBuilder, string("signatureBuilder-v1.1"));
    _setAddress(config.requestBuilder, string("requestBuilder-v1.1"));

    vm.stopBroadcast();
  }

  function _setAddress(address contractAddress, string memory contractName) internal {
    IAddressesProvider sismoAddressProvider = IAddressesProvider(SISMO_ADDRESSES_PROVIDER_V2);
    address currentContractAddress = sismoAddressProvider.get(contractName);

    if (currentContractAddress != contractAddress) {
      console.log(
        "current contract address for ",
        contractName,
        " is different. Updating address to ",
        contractAddress
      );
      sismoAddressProvider.set(contractAddress, contractName);
    } else {
      console.log(
        "current contract address for ",
        contractName,
        " is already the expected one. skipping update"
      );
    }
  }
}
