// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";
import {BaseDeploymentConfig, DeploymentConfig} from "script/BaseConfig.sol";

contract SetAddressesProvider is Script, BaseDeploymentConfig {
  function run() external {
    string memory chainName = vm.envString("CHAIN_NAME");
    _setDeploymentConfig(chainName);

    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Sender:", msg.sender);

    vm.startBroadcast();

    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".sismoConnectVerifier"),
      string("sismoConnectVerifier-v1")
    );
    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".hydraS2Verifier"),
      string("hydraS2Verifier")
    );
    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".availableRootsRegistry"),
      string("sismoConnectAvailableRootsRegistry")
    );
    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".commitmentMapperRegistry"),
      string("sismoConnectCommitmentMapperRegistry")
    );

    // external libraries

    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".authRequestBuilder"),
      string("authRequestBuilder-v1")
    );
    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".claimRequestBuilder"),
      string("claimRequestBuilder-v1")
    );
    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".signatureBuilder"),
      string("signatureBuilder-v1")
    );
    _setAddress(
      _readAddressFromDeploymentConfigAtKey(".requestBuilder"),
      string("requestBuilder-v1")
    );

    vm.stopBroadcast();
  }

  function _setAddress(address contractAddress, string memory contractName) internal {
    IAddressesProvider sismoAddressProvider = IAddressesProvider(SISMO_ADDRESSES_PROVIDER);
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
