// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {CommitmentMapperRegistry} from "../src/periphery/CommitmentMapperRegistry.sol";
import {TransparentUpgradeableProxy} from "./utils/deterministic-deployments/TransparentUpgradeableProxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract DeployCommitmentMapperRegistry is Script, BaseDeploymentConfig {
  bytes32 internal constant SALT = keccak256("sismo-commitment-mapper-registry");
  // create2Factory address from https://github.com/Arachnid/deterministic-deployment-proxy
  address internal constant CREATE2_FACTORY_ADDRESS = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
  address internal constant DETERMINISTIC_DEPLOYMENT_ADDRESS =
    0x2ff87b43dbE95d94F56F059cA3506d5d4E8F0470;

  function run() public returns (CommitmentMapperRegistry) {
    string memory chainName = vm.envString("CHAIN_NAME");
    return runFor(chainName);
  }

  function runFor(string memory chainName) public returns (CommitmentMapperRegistry) {
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    _setDeploymentConfig({chainName: chainName, checkIfEmpty: true});

    address commitmentMapperRegistryAddress = config.commitmentMapperRegistry;
    address owner = config.owner;
    uint256[2] memory commitmentMapperPubKeys = config.commitmentMapperEdDSAPubKey;
    address proxyAdmin = config.proxyAdmin;
    address deployer = msg.sender;

    bytes32 TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH = keccak256(
      abi.encodePacked(
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(CREATE2_FACTORY_ADDRESS, deployer, bytes(""))
      )
    );

    vm.startBroadcast(deployer);

    if ((commitmentMapperRegistryAddress != address(0)) && (!_compareStrings(chainName, "test"))) {
      require(false, "CommitmentMapperRegistry contract is already deployed!");
    }

    if (
      (deployer != 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24) &&
      (!_compareStrings(chainName, "test"))
    ) {
      require(
        false,
        "Only 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24 can deploy CommitmentMapperRegistry contract!"
      );
    }
    if (
      (_getAddress(SALT, TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH, CREATE2_FACTORY_ADDRESS) !=
        DETERMINISTIC_DEPLOYMENT_ADDRESS) && (!_compareStrings(chainName, "test"))
    ) {
      require(
        false,
        "CommitmentMapperRegistry contract address should be 0x2ff87b43dbE95d94F56F059cA3506d5d4E8F0470!"
      );
    }

    console.log("Deploying CommitmentMapperRegistry Proxy...");

    // deterministicly deploy the proxy by porviding the create2Factory address as implementation address
    TransparentUpgradeableProxy commitmentMapperRegistryProxy = new TransparentUpgradeableProxy{
      salt: SALT
    }(CREATE2_FACTORY_ADDRESS, deployer, bytes(""));
    console.log("CommitmentMapperRegistry Proxy Deployed:", address(commitmentMapperRegistryProxy));

    CommitmentMapperRegistry commitmentMapperRegistryImplem = new CommitmentMapperRegistry(
      deployer,
      commitmentMapperPubKeys
    );
    console.log(
      "CommitmentMapperRegistry Implem Deployed:",
      address(commitmentMapperRegistryImplem)
    );

    // Upgrade the proxy to use the correct deployed implementation
    commitmentMapperRegistryProxy.upgradeToAndCall(
      address(commitmentMapperRegistryImplem),
      abi.encodeWithSelector(
        commitmentMapperRegistryImplem.initialize.selector,
        deployer,
        commitmentMapperPubKeys
      )
    );

    if (commitmentMapperRegistryProxy.admin() != proxyAdmin) {
      // change proxy admin to proxyAdmin
      commitmentMapperRegistryProxy.changeAdmin(proxyAdmin);
      console.log("CommitmentMapperRegistry proxy admin changed from", deployer, "to", proxyAdmin);
    }

    CommitmentMapperRegistry commitmentMapperRegistry = CommitmentMapperRegistry(
      address(commitmentMapperRegistryProxy)
    );

    if (commitmentMapperRegistry.owner() != owner) {
      // change owner to owner
      commitmentMapperRegistry.transferOwnership(owner);
      console.log("CommitmentMapperRegistry ownership transferred from", deployer, "to", owner);
    }

    DeploymentConfig memory newDeploymentConfig = DeploymentConfig({
      proxyAdmin: proxyAdmin,
      owner: owner,
      rootsOwner: config.rootsOwner,
      commitmentMapperEdDSAPubKey: commitmentMapperPubKeys,
      sismoAddressesProviderV2: config.sismoAddressesProviderV2,
      availableRootsRegistry: config.availableRootsRegistry,
      commitmentMapperRegistry: address(commitmentMapperRegistry),
      hydraS3Verifier: config.hydraS3Verifier,
      sismoConnectVerifier: config.sismoConnectVerifier,
      authRequestBuilder: config.authRequestBuilder,
      claimRequestBuilder: config.claimRequestBuilder,
      signatureBuilder: config.signatureBuilder,
      requestBuilder: config.requestBuilder
    });

    _saveDeploymentConfig(chainName, newDeploymentConfig);

    vm.stopBroadcast();

    return commitmentMapperRegistry;
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
