// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {AvailableRootsRegistry} from "../src/periphery/AvailableRootsRegistry.sol";
import {TransparentUpgradeableProxy} from "./utils/deterministic-deployments/TransparentUpgradeableProxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract DeployAvailableRootsRegistry is Script, BaseDeploymentConfig {
  bytes32 internal constant SALT = keccak256("sismo-available-roots-registry");
  // create2Factory address from https://github.com/Arachnid/deterministic-deployment-proxy
  address internal constant CREATE2_FACTORY_ADDRESS = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
  address internal constant DETERMINISTIC_DEPLOYMENT_ADDRESS =
    0xfB548eC30347c220E4e7733248ff25e3699A4648;

  function run() public returns (AvailableRootsRegistry) {
    string memory chainName = vm.envString("CHAIN_NAME");
    return runFor(chainName);
  }

  function runFor(string memory chainName) public returns (AvailableRootsRegistry) {
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    _setDeploymentConfig({chainName: chainName, checkIfEmpty: true});

    address availableRootsRegistryAddress = config.availableRootsRegistry;
    address owner = config.owner;
    address proxyAdmin = config.proxyAdmin;
    address deployer = msg.sender;

    bytes32 TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH = keccak256(
      abi.encodePacked(
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(CREATE2_FACTORY_ADDRESS, deployer, bytes(""))
      )
    );

    vm.startBroadcast(deployer);

    if ((availableRootsRegistryAddress != address(0)) && (!_compareStrings(chainName, "test"))) {
      require(false, "AvailableRootsRegistry contract is already deployed!");
    }

    if (
      (deployer != 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24) &&
      (!_compareStrings(chainName, "test"))
    ) {
      require(
        false,
        "Only 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24 can deploy AvailableRootsRegistry contract!"
      );
    }
    if (
      (_getAddress(SALT, TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH, CREATE2_FACTORY_ADDRESS) !=
        DETERMINISTIC_DEPLOYMENT_ADDRESS) && (!_compareStrings(chainName, "test"))
    ) {
      require(
        false,
        "AvailableRootsRegistry contract address should be 0xfB548eC30347c220E4e7733248ff25e3699A4648!"
      );
    }

    console.log("Deploying AvailableRootsRegistry Proxy...");

    // deterministicly deploy the proxy by porviding the create2Factory address as implementation address
    TransparentUpgradeableProxy availableRootsRegistryProxy = new TransparentUpgradeableProxy{
      salt: SALT
    }(CREATE2_FACTORY_ADDRESS, deployer, bytes(""));
    console.log("AvailableRootsRegistry Proxy Deployed:", address(availableRootsRegistryProxy));

    AvailableRootsRegistry availableRootsRegistryImplem = new AvailableRootsRegistry(deployer);
    console.log("AvailableRootsRegistry Implem Deployed:", address(availableRootsRegistryImplem));

    // Upgrade the proxy to use the correct deployed implementation
    availableRootsRegistryProxy.upgradeToAndCall(
      address(availableRootsRegistryImplem),
      abi.encodeWithSelector(availableRootsRegistryImplem.initialize.selector, deployer)
    );

    if (availableRootsRegistryProxy.admin() != proxyAdmin) {
      // change proxy admin to proxyAdmin
      availableRootsRegistryProxy.changeAdmin(proxyAdmin);
      console.log("AvailableRootsRegistry proxy admin changed from", deployer, "to", proxyAdmin);
    }

    AvailableRootsRegistry availableRootsRegistry = AvailableRootsRegistry(
      address(availableRootsRegistryProxy)
    );

    if (availableRootsRegistry.owner() != owner) {
      // transfer ownership to owner
      availableRootsRegistry.transferOwnership(owner);
      console.log("AvailableRootsRegistry ownership transferred from", deployer, "to", owner);
    }

    DeploymentConfig memory newDeploymentConfig = DeploymentConfig({
      proxyAdmin: proxyAdmin,
      owner: owner,
      rootsOwner: config.rootsOwner,
      commitmentMapperEdDSAPubKey: config.commitmentMapperEdDSAPubKey,
      sismoAddressesProviderV2: config.sismoAddressesProviderV2,
      availableRootsRegistry: address(availableRootsRegistry),
      commitmentMapperRegistry: config.commitmentMapperRegistry,
      hydraS3Verifier: config.hydraS3Verifier,
      sismoConnectVerifier: config.sismoConnectVerifier,
      authRequestBuilder: config.authRequestBuilder,
      claimRequestBuilder: config.claimRequestBuilder,
      signatureBuilder: config.signatureBuilder,
      requestBuilder: config.requestBuilder
    });

    _saveDeploymentConfig(chainName, newDeploymentConfig);

    vm.stopBroadcast();

    return availableRootsRegistry;
  }

  function _getAddress(
    bytes32 _salt,
    bytes32 _initCodeHash,
    address create2FactoryAddress
  ) private pure returns (address) {
    address deterministicAddress = Create2.computeAddress(
      _salt,
      _initCodeHash,
      create2FactoryAddress
    );
    return deterministicAddress;
  }
}
