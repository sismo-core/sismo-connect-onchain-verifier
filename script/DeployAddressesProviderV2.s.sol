// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {AddressesProviderV2} from "../src/periphery/AddressesProviderV2.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployAddressesProviderV2 is Script, BaseDeploymentConfig {
  bytes32 internal constant SALT = keccak256("sismo-addresses-provider-v2");

  function run() public {
    string memory chainName = vm.envString("CHAIN_NAME");
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    _setDeploymentConfig({chainName: chainName, checkIfEmpty: true});

    address addressesProviderV2Address = _readAddressFromDeploymentConfigAtKey(
      ".addressesProviderV2"
    );
    address owner = _readAddressFromDeploymentConfigAtKey(".owner");
    address proxyAdmin = _readAddressFromDeploymentConfigAtKey(".proxyAdmin");
    address deployer = msg.sender;

    vm.startBroadcast(deployer);

    if (addressesProviderV2Address != address(0)) {
      require(false, "AddressesPoviderV2 contract is already deployed!");
    }

    console.log("Deploying AddressesPoviderV2 Proxy...");

    TransparentUpgradeableProxy addressesProviderV2 = new TransparentUpgradeableProxy{salt: SALT}(
      0x4e59b44847b379578588920cA78FbF26c0B4956C, // create2Factory address from https://github.com/Arachnid/deterministic-deployment-proxy
      deployer,
      bytes("")
    );
    console.log("AddressesPoviderV2 Proxy Deployed:", address(addressesProviderV2));

    AddressesProviderV2 addressesProviderV2Implem = new AddressesProviderV2(deployer);
    console.log("AddressesPoviderV2 Implem Deployed:", address(addressesProviderV2Implem));

    // Upgrade the proxy to use the deployed implementation
    addressesProviderV2.upgradeToAndCall(
      address(addressesProviderV2Implem),
      abi.encodeWithSelector(addressesProviderV2Implem.initialize.selector, deployer)
    );
    console.log("AddressesPoviderV2 Proxy Upgraded to:", address(addressesProviderV2Implem));

    // change proxy admin
    addressesProviderV2.changeAdmin(proxyAdmin);
    console.log("AddressesPoviderV2 Proxy Admin Changed from", deployer, "to", proxyAdmin);

    // transfer ownership to owner
    addressesProviderV2Implem.transferOwnership(owner);
    console.log("AddressesPoviderV2 Ownership Transferred from", deployer, "to", owner);

    DeploymentConfig memory newDeploymentConfig = DeploymentConfig({
      proxyAdmin: _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      owner: _readAddressFromDeploymentConfigAtKey(".owner"),
      rootsOwner: _readAddressFromDeploymentConfigAtKey(".rootsOwner"),
      commitmentMapperEdDSAPubKey: _readCommitmentMapperEdDSAPubKeyFromDeploymentConfig(),
      sismoAddressesProvider: address(addressesProviderV2),
      availableRootsRegistry: _readAddressFromDeploymentConfigAtKey(".availableRootsRegistry"),
      commitmentMapperRegistry: _readAddressFromDeploymentConfigAtKey(".commitmentMapperRegistry"),
      hydraS3Verifier: _readAddressFromDeploymentConfigAtKey(".hydraS3Verifier"),
      sismoConnectVerifier: _readAddressFromDeploymentConfigAtKey(".sismoConnectVerifier"),
      authRequestBuilder: _readAddressFromDeploymentConfigAtKey(".authRequestBuilder"),
      claimRequestBuilder: _readAddressFromDeploymentConfigAtKey(".claimRequestBuilder"),
      signatureBuilder: _readAddressFromDeploymentConfigAtKey(".signatureBuilder"),
      requestBuilder: _readAddressFromDeploymentConfigAtKey(".requestBuilder")
    });

    _saveDeploymentConfig(chainName, newDeploymentConfig);

    vm.stopBroadcast();
  }
}
