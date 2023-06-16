// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {AddressesProviderV2} from "../src/periphery/AddressesProviderV2.sol";
import {TransparentUpgradeableProxy} from "./utils/deterministic-deployments/TransparentUpgradeableProxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract DeployAddressesProviderV2 is Script, BaseDeploymentConfig {
  bytes32 internal constant SALT = keccak256("sismo-addresses-provider-V2");
  // create2Factory address from https://github.com/Arachnid/deterministic-deployment-proxy
  address internal constant CREATE2_FACTORY_ADDRESS = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
  address internal constant DETERMINISTIC_DEPLOYMENT_ADDRESS =
    0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6;

  function run() public returns (AddressesProviderV2) {
    string memory chainName = vm.envString("CHAIN_NAME");
    return runFor(chainName);
  }

  function runFor(string memory chainName) public returns (AddressesProviderV2) {
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    _setDeploymentConfig({chainName: chainName, checkIfEmpty: true});

    address addressesProviderV2Address = config.sismoAddressesProviderV2;
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

    if (addressesProviderV2Address != address(0)) {
      require(false, "AddressesPoviderV2 contract is already deployed!");
    }

    if (deployer != 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24) {
      require(
        false,
        "Only 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24 can deploy AddressesPoviderV2 contract!"
      );
    }
    if (
      _getAddress(SALT, TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH, CREATE2_FACTORY_ADDRESS) !=
      DETERMINISTIC_DEPLOYMENT_ADDRESS
    ) {
      require(
        false,
        "AddressesPoviderV2 contract address should be 0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6!"
      );
    }

    console.log("Deploying AddressesPoviderV2 Proxy...");

    // deterministicly deploy the proxy by porviding the create2Factory address as implementation address
    TransparentUpgradeableProxy addressesProviderV2Proxy = new TransparentUpgradeableProxy{
      salt: SALT
    }(CREATE2_FACTORY_ADDRESS, deployer, bytes(""));
    console.log("AddressesPoviderV2 Proxy Deployed:", address(addressesProviderV2Proxy));

    AddressesProviderV2 addressesProviderV2Implem = new AddressesProviderV2(deployer);
    console.log("AddressesPoviderV2 Implem Deployed:", address(addressesProviderV2Implem));

    // Upgrade the proxy to use the correct deployed implementation
    addressesProviderV2Proxy.upgradeToAndCall(
      address(addressesProviderV2Implem),
      abi.encodeWithSelector(addressesProviderV2Implem.initialize.selector, deployer)
    );

    // change proxy admin to proxyAdmin
    if (addressesProviderV2Proxy.admin() != proxyAdmin) {
      addressesProviderV2Proxy.changeAdmin(proxyAdmin);
      console.log("AddressesPoviderV2 proxy admin changed from", deployer, "to", proxyAdmin);
    }

    AddressesProviderV2 addressesProviderV2 = AddressesProviderV2(
      address(addressesProviderV2Proxy)
    );

    // transfer ownership to owner
    if (addressesProviderV2.owner() != owner) {
      addressesProviderV2.transferOwnership(owner);
      console.log("AddressesPoviderV2 ownership transferred from", deployer, "to", owner);
    }

    DeploymentConfig memory newDeploymentConfig = DeploymentConfig({
      proxyAdmin: config.proxyAdmin,
      owner: config.owner,
      rootsOwner: config.rootsOwner,
      commitmentMapperEdDSAPubKey: config.commitmentMapperEdDSAPubKey,
      sismoAddressesProviderV2: address(addressesProviderV2),
      availableRootsRegistry: config.availableRootsRegistry,
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

    return addressesProviderV2;
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
