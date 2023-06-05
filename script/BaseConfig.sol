// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";

// struct fields are sorted by alphabetical order to be able to parse the config from the deployment files
struct DeploymentConfig {
  address authRequestBuilder;
  address availableRootsRegistry;
  address claimRequestBuilder;
  uint256[2] commitmentMapperEdDSAPubKey;
  address commitmentMapperRegistry;
  address hydraS2Verifier;
  address owner;
  address proxyAdmin;
  address requestBuilder;
  address rootsOwner;
  address signatureBuilder;
  address sismoAddressesProvider;
  address sismoConnectVerifier;
}

// Minimal config is used to create empty config files
struct MinimalConfig {
  address owner;
  address proxyAdmin;
  address rootsOwner;
  uint256[2] commitmentMapperEdDSAPubKey;
}

contract BaseDeploymentConfig is Script {
  MinimalConfig minimalConfig;
  DeploymentConfig config;

  address immutable SISMO_ADDRESSES_PROVIDER = 0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05;
  address immutable ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

  // Main Env
  address immutable MAIN_PROXY_ADMIN = 0x2110475dfbB8d331b300178A867372991ff35fA3;
  address immutable MAIN_OWNER = 0x00c92065F759c3d1c94d08C27a2Ab97a1c874Cbc;
  address immutable MAIN_GNOSIS_ROOTS_OWNER = 0xEf809a50de35c762FBaCf1ae1F6B861CE42911D1;
  address immutable MAIN_POLYGON_ROOTS_OWNER = 0xF0a0B692e1c764281c211948D03edEeF5Fb57111;
  address immutable MAIN_MAINNET_ROOTS_OWNER = 0x2a265b954B96d4940B94eb69E8Fc8E7346369D05;

  // Testnet Env
  address immutable TESTNET_PROXY_ADMIN = 0x246E71bC2a257f4BE9C7fAD4664E6D7444844Adc;
  address immutable TESTNET_OWNER = 0xBB8FcA8f2381CFeEDe5D7541d7bF76343EF6c67B;
  address immutable TESTNET_GOERLI_ROOTS_OWNER = 0xa687922C4bf2eB22297FdF89156B49eD3727618b;
  address immutable TESTNET_MUMBAI_ROOTS_OWNER = 0xCA0583A6682607282963d3E2545Cd2e75697C2bb;
  address immutable TESTNET_SCROLL_GOERLI_ROOTS_OWNER = 0x8f9c04d7bA132Fd0CbA124eFCE3936328d217458;

  // Sismo Staging env (Sismo internal use only)
  address immutable STAGING_PROXY_ADMIN = 0x246E71bC2a257f4BE9C7fAD4664E6D7444844Adc;
  address immutable STAGING_OWNER = 0xBB8FcA8f2381CFeEDe5D7541d7bF76343EF6c67B;
  address immutable STAGING_GOERLI_ROOTS_OWNER = 0x7f2e6E158643BCaF85f30c57Ae8625f623D82659;
  address immutable STAGING_MUMBAI_ROOTS_OWNER = 0x63F08f8F13126B9eADC76dd683902C61c5115138;

  // commitment mapper pubkeys
  uint256 immutable PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X =
    0x07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb9;
  uint256 immutable PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y =
    0x20706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa;

  uint256 immutable DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X =
    0x2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f0256;
  uint256 immutable DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y =
    0x30423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74;

  error ChainNotConfigured(DeployChain chain);
  error ChainNameNotFound(string chainName);

  enum DeployChain {
    Mainnet,
    Gnosis,
    Polygon,
    TestnetGoerli,
    TestnetMumbai,
    ScrollTestnetGoerli,
    StagingGoerli,
    StagingMumbai,
    Test
  }

  function getChainName(string memory chainName) internal pure returns (DeployChain) {
    if (_compareStrings(chainName, "mainnet")) {
      return DeployChain.Mainnet;
    } else if (_compareStrings(chainName, "gnosis")) {
      return DeployChain.Gnosis;
    } else if (_compareStrings(chainName, "polygon")) {
      return DeployChain.Polygon;
    } else if (_compareStrings(chainName, "testnet-goerli")) {
      return DeployChain.TestnetGoerli;
    } else if (_compareStrings(chainName, "testnet-mumbai")) {
      return DeployChain.TestnetMumbai;
    } else if (_compareStrings(chainName, "scroll-testnet-goerli")) {
      return DeployChain.ScrollTestnetGoerli;
    } else if (_compareStrings(chainName, "staging-goerli")) {
      return DeployChain.StagingGoerli;
    } else if (_compareStrings(chainName, "staging-mumbai")) {
      return DeployChain.StagingMumbai;
    } else if (_compareStrings(chainName, "test")) {
      return DeployChain.Test;
    }
    revert ChainNameNotFound(chainName);
  }

  function _getEmptyDeploymentConfig(DeployChain chain) internal returns (DeploymentConfig memory) {
    if (chain == DeployChain.Mainnet) {
      minimalConfig = MinimalConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_MAINNET_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.Gnosis) {
      minimalConfig = MinimalConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_GNOSIS_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.Polygon) {
      minimalConfig = MinimalConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_POLYGON_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.TestnetGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.TestnetMumbai) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_MUMBAI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.ScrollTestnetGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_SCROLL_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.StagingGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: STAGING_PROXY_ADMIN,
        owner: STAGING_OWNER,
        rootsOwner: STAGING_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.StagingMumbai) {
      minimalConfig = MinimalConfig({
        proxyAdmin: STAGING_PROXY_ADMIN,
        owner: STAGING_OWNER,
        rootsOwner: STAGING_MUMBAI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.Test) {
      minimalConfig = MinimalConfig({
        proxyAdmin: address(1),
        owner: address(2),
        rootsOwner: address(3),
        commitmentMapperEdDSAPubKey: [uint256(10), uint256(11)]
      });
    } else {
      revert ChainNotConfigured(chain);
    }

    config = DeploymentConfig({
      proxyAdmin: minimalConfig.proxyAdmin,
      owner: minimalConfig.owner,
      rootsOwner: minimalConfig.rootsOwner,
      commitmentMapperEdDSAPubKey: minimalConfig.commitmentMapperEdDSAPubKey,
      availableRootsRegistry: ZERO_ADDRESS,
      commitmentMapperRegistry: ZERO_ADDRESS,
      sismoAddressesProvider: SISMO_ADDRESSES_PROVIDER,
      sismoConnectVerifier: ZERO_ADDRESS,
      hydraS2Verifier: ZERO_ADDRESS,
      // external libraries
      authRequestBuilder: ZERO_ADDRESS,
      claimRequestBuilder: ZERO_ADDRESS,
      signatureBuilder: ZERO_ADDRESS,
      requestBuilder: ZERO_ADDRESS
    });

    return config;
  }

  function _readDeploymentConfig(
    string memory chainName
  ) internal returns (DeploymentConfig memory) {
    if (_compareStrings(chainName, "test")) {
      config = DeploymentConfig({
        proxyAdmin: address(1),
        owner: address(2),
        rootsOwner: address(3),
        commitmentMapperEdDSAPubKey: [uint256(10), uint256(11)],
        availableRootsRegistry: ZERO_ADDRESS,
        commitmentMapperRegistry: ZERO_ADDRESS,
        sismoAddressesProvider: ZERO_ADDRESS,
        sismoConnectVerifier: ZERO_ADDRESS,
        hydraS2Verifier: ZERO_ADDRESS,
        // external libraries
        authRequestBuilder: ZERO_ADDRESS,
        claimRequestBuilder: ZERO_ADDRESS,
        signatureBuilder: ZERO_ADDRESS,
        requestBuilder: ZERO_ADDRESS
      });
      return config;
    }

    // read deployment config from file if the chain is different from `test`
    string memory filePath = string.concat(
      vm.projectRoot(),
      "/script/deployments/",
      chainName,
      ".json"
    );

    string memory json = vm.readFile(filePath);

    // if the config is not created, create a new empty one
    if (_compareStrings(json, "")) {
      _saveDeploymentConfig(chainName, _getEmptyDeploymentConfig(getChainName(chainName)));
      json = vm.readFile(filePath);
    }

    // make sure that the DeploymentConfig struct has its field in alphabetical order to avoid errors
    config = abi.decode(vm.parseJson(json), (DeploymentConfig));

    return config;
  }

  function _saveDeploymentConfig(
    string memory chainName,
    DeploymentConfig memory deploymentConfig
  ) internal {
    string memory filePath = string.concat(
      vm.projectRoot(),
      "/script/deployments/",
      chainName,
      ".json"
    );

    // serialize deployment config by creating an object with key `chainName`
    vm.serializeAddress(
      chainName,
      "availableRootsRegistry",
      address(deploymentConfig.availableRootsRegistry)
    );
    vm.serializeAddress(
      chainName,
      "commitmentMapperRegistry",
      address(deploymentConfig.commitmentMapperRegistry)
    );
    vm.serializeAddress(chainName, "hydraS2Verifier", address(deploymentConfig.hydraS2Verifier));
    vm.serializeAddress(
      chainName,
      "sismoConnectVerifier",
      address(deploymentConfig.sismoConnectVerifier)
    );
    vm.serializeAddress(
      chainName,
      "authRequestBuilder",
      address(deploymentConfig.authRequestBuilder)
    );
    vm.serializeAddress(
      chainName,
      "claimRequestBuilder",
      address(deploymentConfig.claimRequestBuilder)
    );
    vm.serializeAddress(chainName, "signatureBuilder", address(deploymentConfig.signatureBuilder));
    vm.serializeAddress(chainName, "requestBuilder", address(deploymentConfig.requestBuilder));
    vm.serializeAddress(chainName, "proxyAdmin", address(deploymentConfig.proxyAdmin));
    vm.serializeAddress(chainName, "owner", address(deploymentConfig.owner));
    vm.serializeAddress(chainName, "rootsOwner", address(deploymentConfig.rootsOwner));

    // serialize commitment mapper pub key by creating a new json object with key "commitmentMapperEdDSAPubKey
    vm.serializeUint(
      "commitmentMapperEdDSAPubKey",
      "pubKeyX",
      deploymentConfig.commitmentMapperEdDSAPubKey[0]
    );
    string memory commitmentMapperPubKeyConfig = vm.serializeUint(
      "commitmentMapperEdDSAPubKey",
      "pubKeyY",
      deploymentConfig.commitmentMapperEdDSAPubKey[1]
    );

    // serialize this json object as a string to be able to save it in the main json object with key `chainName`
    vm.serializeString(chainName, "commitmentMapperEdDSAPubKey", commitmentMapperPubKeyConfig);
    string memory finalJson = vm.serializeAddress(
      chainName,
      "sismoAddressesProvider",
      SISMO_ADDRESSES_PROVIDER
    );

    vm.writeJson(finalJson, filePath);
  }

  function _compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  /// @dev broadcast transaction modifier
  /// @param pk private key to broadcast transaction
  modifier broadcast(uint256 pk) {
    vm.startBroadcast(pk);

    _;

    vm.stopBroadcast();
  }
}
