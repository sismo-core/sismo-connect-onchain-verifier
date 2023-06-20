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
  address hydraS3Verifier;
  address owner;
  address proxyAdmin;
  address requestBuilder;
  address rootsOwner;
  address signatureBuilder;
  address sismoAddressesProviderV2;
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

  string public _chainName;
  bool public _checkIfEmpty;

  address immutable SISMO_ADDRESSES_PROVIDER_V2 = 0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6;
  address immutable ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;

  // Main Env
  address immutable MAIN_PROXY_ADMIN = 0x2110475dfbB8d331b300178A867372991ff35fA3;
  address immutable MAIN_OWNER = 0x00c92065F759c3d1c94d08C27a2Ab97a1c874Cbc;
  address immutable MAIN_GNOSIS_ROOTS_OWNER = 0xEf809a50de35c762FBaCf1ae1F6B861CE42911D1;
  address immutable MAIN_POLYGON_ROOTS_OWNER = 0xF0a0B692e1c764281c211948D03edEeF5Fb57111;
  address immutable MAIN_OPTIMISM_ROOTS_OWNER = 0xf8640cE5532BCbc788489Bf5A786635ae585258B;
  address immutable MAIN_ARBITRUM_ONE_ROOTS_OWNER = 0x1BB9AD70F529e36B7Ffed0cfA44fA4cf0213Fa09;
  address immutable MAIN_MAINNET_ROOTS_OWNER = 0x2a265b954B96d4940B94eb69E8Fc8E7346369D05;

  // Testnet Env
  address immutable TESTNET_PROXY_ADMIN = 0x246E71bC2a257f4BE9C7fAD4664E6D7444844Adc;
  address immutable TESTNET_OWNER = 0xBB8FcA8f2381CFeEDe5D7541d7bF76343EF6c67B;
  address immutable TESTNET_GOERLI_ROOTS_OWNER = 0xa687922C4bf2eB22297FdF89156B49eD3727618b;
  address immutable TESTNET_SEPOLIA_ROOTS_OWNER = 0x1C0c54EA7Bb55f655fb8Ff6D51557368bA8624E6;
  address immutable TESTNET_MUMBAI_ROOTS_OWNER = 0xCA0583A6682607282963d3E2545Cd2e75697C2bb;
  address immutable TESTNET_OPTIMISM_GOERLI_ROOTS_OWNER =
    0xe807B5153e3eD4767C3F4EB50b65Fab90c57596B;
  address immutable TESTNET_ARBITRUM_GOERLI_ROOTS_OWNER =
    0x8eAb4616d47F82C890fdb6eE311A4C0aE34ba7fb;
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

  error ChainNotConfigured(DeployChain chain);
  error ChainNameNotFound(string chainName);

  enum DeployChain {
    Mainnet,
    Gnosis,
    Polygon,
    Optimism,
    ArbitrumOne,
    TestnetGoerli,
    TestnetSepolia,
    TestnetMumbai,
    OptimismGoerli,
    ArbitrumGoerli,
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
    } else if (_compareStrings(chainName, "optimism")) {
      return DeployChain.Optimism;
    } else if (_compareStrings(chainName, "arbitrum-one")) {
      return DeployChain.ArbitrumOne;
    } else if (_compareStrings(chainName, "testnet-goerli")) {
      return DeployChain.TestnetGoerli;
    } else if (_compareStrings(chainName, "testnet-sepolia")) {
      return DeployChain.TestnetSepolia;
    } else if (_compareStrings(chainName, "testnet-mumbai")) {
      return DeployChain.TestnetMumbai;
    } else if (_compareStrings(chainName, "optimism-goerli")) {
      return DeployChain.OptimismGoerli;
    } else if (_compareStrings(chainName, "arbitrum-goerli")) {
      return DeployChain.ArbitrumGoerli;
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
    minimalConfig = _getMinimalConfig(chain);

    config = DeploymentConfig({
      proxyAdmin: minimalConfig.proxyAdmin,
      owner: minimalConfig.owner,
      rootsOwner: minimalConfig.rootsOwner,
      commitmentMapperEdDSAPubKey: minimalConfig.commitmentMapperEdDSAPubKey,
      availableRootsRegistry: ZERO_ADDRESS,
      commitmentMapperRegistry: ZERO_ADDRESS,
      sismoAddressesProviderV2: _tryReadingAddressFromDeploymentConfigAtKey(
        ".sismoAddressesProviderV2"
      ),
      sismoConnectVerifier: ZERO_ADDRESS,
      hydraS3Verifier: ZERO_ADDRESS,
      // external libraries
      authRequestBuilder: ZERO_ADDRESS,
      claimRequestBuilder: ZERO_ADDRESS,
      signatureBuilder: ZERO_ADDRESS,
      requestBuilder: ZERO_ADDRESS
    });

    return config;
  }

  function _getMinimalConfig(DeployChain chain) internal returns (MinimalConfig memory) {
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
    } else if (chain == DeployChain.Optimism) {
      minimalConfig = MinimalConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_OPTIMISM_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.ArbitrumOne) {
      minimalConfig = MinimalConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_ARBITRUM_ONE_ROOTS_OWNER,
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
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.TestnetSepolia) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_SEPOLIA_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.TestnetMumbai) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_MUMBAI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.OptimismGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_OPTIMISM_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.ArbitrumGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_ARBITRUM_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.ScrollTestnetGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_SCROLL_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.StagingGoerli) {
      minimalConfig = MinimalConfig({
        proxyAdmin: STAGING_PROXY_ADMIN,
        owner: STAGING_OWNER,
        rootsOwner: STAGING_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployChain.StagingMumbai) {
      minimalConfig = MinimalConfig({
        proxyAdmin: STAGING_PROXY_ADMIN,
        owner: STAGING_OWNER,
        rootsOwner: STAGING_MUMBAI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
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

    return minimalConfig;
  }

  function _setDeploymentConfig(string memory chainName, bool checkIfEmpty) internal {
    _chainName = chainName;
    _checkIfEmpty = checkIfEmpty;
    // read deployment config from file if the chain is different from `test`
    string memory filePath = string.concat(_deploymentConfigFilePath());

    string memory json;
    try vm.readFile(filePath) returns (string memory _json) {
      json = _json;
    } catch {
      console.log(
        string.concat("Deployment config file not found, creating a new one at ", filePath, ".")
      );
      // create a new empty file
      vm.writeFile(filePath, "");
      json = "";
    }

    // if the config is not created, create a new empty one
    if (checkIfEmpty) {
      if (_compareStrings(json, "") || _compareStrings(chainName, "test") || _isLocalFork()) {
        _saveDeploymentConfig(chainName, _getEmptyDeploymentConfig(getChainName(_chainName)));
      } else {
        _readDeploymentConfig(_chainName);
      }
    } else {
      _readDeploymentConfig(_chainName);
    }
  }

  function _readDeploymentConfig(string memory chainName) internal {
    _chainName = chainName;
    minimalConfig = _getMinimalConfig(getChainName(chainName));
    address owner = minimalConfig.owner;
    address proxyAdmin = minimalConfig.proxyAdmin;
    address rootsOwner = minimalConfig.rootsOwner;
    uint256[2] memory commitmentMapperEdDSAPubKey = minimalConfig.commitmentMapperEdDSAPubKey;
    address availableRootsRegistry = _tryReadingAddressFromDeploymentConfigAtKey(
      ".availableRootsRegistry"
    );
    address commitmentMapperRegistry = _tryReadingAddressFromDeploymentConfigAtKey(
      ".commitmentMapperRegistry"
    );
    address sismoAddressesProviderV2 = _tryReadingAddressFromDeploymentConfigAtKey(
      ".sismoAddressesProviderV2"
    );
    address sismoConnectVerifier = _tryReadingAddressFromDeploymentConfigAtKey(
      ".sismoConnectVerifier"
    );
    address hydraS3Verifier = _tryReadingAddressFromDeploymentConfigAtKey(".hydraS3Verifier");
    address authRequestBuilder = _tryReadingAddressFromDeploymentConfigAtKey(".authRequestBuilder");
    address claimRequestBuilder = _tryReadingAddressFromDeploymentConfigAtKey(
      ".claimRequestBuilder"
    );
    address signatureBuilder = _tryReadingAddressFromDeploymentConfigAtKey(".signatureBuilder");
    address requestBuilder = _tryReadingAddressFromDeploymentConfigAtKey(".requestBuilder");

    config = DeploymentConfig({
      proxyAdmin: proxyAdmin,
      owner: owner,
      rootsOwner: rootsOwner,
      commitmentMapperEdDSAPubKey: commitmentMapperEdDSAPubKey,
      availableRootsRegistry: availableRootsRegistry,
      commitmentMapperRegistry: commitmentMapperRegistry,
      sismoAddressesProviderV2: sismoAddressesProviderV2,
      sismoConnectVerifier: sismoConnectVerifier,
      hydraS3Verifier: hydraS3Verifier,
      // external libraries
      authRequestBuilder: authRequestBuilder,
      claimRequestBuilder: claimRequestBuilder,
      signatureBuilder: signatureBuilder,
      requestBuilder: requestBuilder
    });
  }

  function _readAddressFromDeploymentConfigAtKey(
    string memory key
  ) internal view returns (address) {
    bytes memory encodedAddress = vm.parseJson(vm.readFile(_deploymentConfigFilePath()), key);
    return
      abi.decode(encodedAddress, (address)) == address(0x20)
        ? address(0)
        : abi.decode(encodedAddress, (address));
  }

  function _tryReadingAddressFromDeploymentConfigAtKey(
    string memory key
  ) internal view returns (address) {
    try vm.parseJson(vm.readFile(_deploymentConfigFilePath()), key) returns (
      bytes memory encodedAddress
    ) {
      return
        abi.decode(encodedAddress, (address)) == address(0x20)
          ? address(0)
          : abi.decode(encodedAddress, (address));
    } catch {
      return ZERO_ADDRESS;
    }
  }

  function _readCommitmentMapperEdDSAPubKeyFromDeploymentConfig()
    internal
    view
    returns (uint256[2] memory pubKey)
  {
    try
      vm.parseJson(vm.readFile(_deploymentConfigFilePath()), ".commitmentMapperEdDSAPubKey")
    returns (bytes memory value) {
      return abi.decode(value, (uint256[2]));
    } catch {
      require(
        false,
        string.concat(
          "Error reading commitmentMapperEdDSAPubKey from deployment config, you need to specify a public key."
        )
      );
    }
  }

  function _tryReadingCommitmentMapperEdDSAPubKeyFromDeploymentConfig()
    internal
    view
    returns (uint256[2] memory pubKey)
  {
    try
      vm.parseJson(vm.readFile(_deploymentConfigFilePath()), ".commitmentMapperEdDSAPubKey")
    returns (bytes memory value) {
      return abi.decode(value, (uint256[2]));
    } catch {
      return [uint256(0), uint256(0)];
    }
  }

  function _saveDeploymentConfig(
    string memory chainName,
    DeploymentConfig memory deploymentConfig
  ) internal {
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
    vm.serializeAddress(chainName, "hydraS3Verifier", address(deploymentConfig.hydraS3Verifier));
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
      "sismoAddressesProviderV2",
      address(deploymentConfig.sismoAddressesProviderV2)
    );

    if (_compareStrings(chainName, "test") || _isLocalFork()) {
      vm.writeJson(finalJson, _deploymentConfigFilePath());
    } else {
      try vm.envBool("OVERRIDE_DEPLOYMENT_CONFIG") returns (bool overrideDeploymentConfig) {
        if (overrideDeploymentConfig == true) {
          vm.writeJson(finalJson, _deploymentConfigFilePath());
        }
      } catch {
        console.log("OVERRIDE_DEPLOYMENT_CONFIG not set, skipping deployment config override.");
      }
    }
  }

  function _deploymentConfigFilePath() internal view returns (string memory) {
    // we return the real config if USE_DEPLOYMENT_CONFIG is true
    // and the RPC_URL is different from localhost
    // otherwise we return the temporary config
    try vm.envBool("USE_DEPLOYMENT_CONFIG") returns (bool useDeploymentConfig) {
      return _checkLocalhostFork(useDeploymentConfig == true);
    } catch {
      return _checkLocalhostFork(false);
    }
  }

  function _checkLocalhostFork(bool useDeploymentConfig) internal view returns (string memory) {
    // check if we are using a fork
    bool isLocalFork = _isLocalFork();

    // if the chainId is different from 31337 (localhost) we need to check if the user wants to use the real development config
    // otherwise it can be dangerous to deploy to a real chain with a config that is temporary
    if (!_compareStrings(vm.toString(block.chainid), "31337")) {
      require(
        useDeploymentConfig == true || isLocalFork == true,
        "If you want to deploy to a chain different from localhost, you either need to use the deployment config by specifying `USE_DEPLOYMENT_CONFIG=true` in your command. Or set `FORK=true` and `--rpc-url http://localhost:8545` in your command to deploy to a fork."
      );
      require(
        !_compareStrings(_chainName, "test"),
        "If you want to deploy to a chain different from localhost, you need to specify a chain name different from `test`."
      );
      // return the real config if we are NOT using a fork
      return
        isLocalFork == true
          ? string.concat(vm.projectRoot(), "/deployments/tmp/", _chainName, ".json")
          : string.concat(vm.projectRoot(), "/deployments/", _chainName, ".json");
    }
    // return the temporary config
    return string.concat(vm.projectRoot(), "/deployments/tmp/", _chainName, ".json");
  }

  function _isLocalFork() internal view returns (bool) {
    bool isLocalFork;
    try vm.envBool("FORK") returns (bool fork) {
      isLocalFork = fork;
    } catch {
      isLocalFork = false;
    }
    return isLocalFork;
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
