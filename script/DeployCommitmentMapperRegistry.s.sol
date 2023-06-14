// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {CommitmentMapperRegistry} from "../src/periphery/CommitmentMapperRegistry.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract DeployCommitmentMapperRegistry is Script, BaseDeploymentConfig {
  bytes32 internal constant SALT = keccak256("sismo-commitment-mapper-registry");
  // create2Factory address from https://github.com/Arachnid/deterministic-deployment-proxy
  address internal constant CREATE2_FACTORY_ADDRESS = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
  address internal constant DETERMINISTIC_DEPLOYMENT_ADDRESS =
    0x4D9D4234f8E21a85665470e222A4945A18088B79;

  function run() public {
    string memory chainName = vm.envString("CHAIN_NAME");
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    _setDeploymentConfig({chainName: chainName, checkIfEmpty: true});

    address commitmentMapperRegistryAddress = _readAddressFromDeploymentConfigAtKey(
      ".commitmentMapperRegistry"
    );
    address owner = _readAddressFromDeploymentConfigAtKey(".owner");
    uint256[2]
      memory commitmentMapperPubKeys = _readCommitmentMapperEdDSAPubKeyFromDeploymentConfig();
    address proxyAdmin = _readAddressFromDeploymentConfigAtKey(".proxyAdmin");
    address deployer = msg.sender;

    bytes32 TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH = keccak256(
      abi.encodePacked(
        type(TransparentUpgradeableProxy).creationCode,
        abi.encode(CREATE2_FACTORY_ADDRESS, deployer, bytes(""))
      )
    );

    vm.startBroadcast(deployer);

    if (commitmentMapperRegistryAddress != address(0)) {
      require(false, "AddressesPoviderV2 contract is already deployed!");
    }

    if (deployer != 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24) {
      require(
        false,
        "Only 0x36D79cf2448b6063DdA4338352da4AFD4C16bf24 can deploy CommitmentMapperRegistry contract!"
      );
    }
    console.log(
      _getAddress(SALT, TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH, CREATE2_FACTORY_ADDRESS)
    );
    if (
      _getAddress(SALT, TRANSPARENT_UPGRADEABLE_PROXY_INIT_CODE_HASH, CREATE2_FACTORY_ADDRESS) !=
      DETERMINISTIC_DEPLOYMENT_ADDRESS
    ) {
      require(
        false,
        "CommitmentMapperRegistry contract address should be 0x4D9D4234f8E21a85665470e222A4945A18088B79!"
      );
    }

    console.log("Deploying CommitmentMapperRegistry Proxy...");

    // deterministicly deploy the proxy by porviding the create2Factory address as implementation address
    TransparentUpgradeableProxy commitmentMapperRegistry = new TransparentUpgradeableProxy{
      salt: SALT
    }(CREATE2_FACTORY_ADDRESS, deployer, bytes(""));
    console.log("CommitmentMapperRegistry Proxy Deployed:", address(commitmentMapperRegistry));

    CommitmentMapperRegistry commitmentMapperRegistryImplem = new CommitmentMapperRegistry(
      deployer,
      commitmentMapperPubKeys
    );
    console.log(
      "CommitmentMapperRegistry Implem Deployed:",
      address(commitmentMapperRegistryImplem)
    );

    // Upgrade the proxy to use the correct deployed implementation
    commitmentMapperRegistry.upgradeToAndCall(
      address(commitmentMapperRegistryImplem),
      abi.encodeWithSelector(
        commitmentMapperRegistryImplem.initialize.selector,
        deployer,
        commitmentMapperPubKeys
      )
    );

    // change proxy admin to proxyAdmin
    commitmentMapperRegistry.changeAdmin(proxyAdmin);
    console.log("CommitmentMapperRegistry proxy admin changed from", deployer, "to", proxyAdmin);

    // transfer ownership to owner
    commitmentMapperRegistryImplem.transferOwnership(owner);
    console.log("CommitmentMapperRegistry ownership transferred from", deployer, "to", owner);

    DeploymentConfig memory newDeploymentConfig = DeploymentConfig({
      proxyAdmin: _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      owner: _readAddressFromDeploymentConfigAtKey(".owner"),
      rootsOwner: _readAddressFromDeploymentConfigAtKey(".rootsOwner"),
      commitmentMapperEdDSAPubKey: commitmentMapperPubKeys,
      sismoAddressesProvider: _readAddressFromDeploymentConfigAtKey(".sismoAddressesProviderV2"),
      availableRootsRegistry: _readAddressFromDeploymentConfigAtKey(".availableRootsRegistry"),
      commitmentMapperRegistry: address(commitmentMapperRegistry),
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
