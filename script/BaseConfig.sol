// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";

struct DeploymentConfig {
  address proxyAdmin;
  address owner;
  address rootsOwner;
  uint256[2] commitmentMapperEdDSAPubKey;
}

contract BaseDeploymentConfig is Script {
  DeploymentConfig public config;

  // Main Env
  address immutable MAIN_PROXY_ADMIN = 0x2110475dfbB8d331b300178A867372991ff35fA3;
  address immutable MAIN_OWNER = 0xaee4acd5c4Bf516330ca8fe11B07206fC6709294;
  address immutable MAIN_GNOSIS_ROOTS_OWNER = 0xEf809a50de35c762FBaCf1ae1F6B861CE42911D1;
  address immutable MAIN_POLYGON_ROOTS_OWNER = 0xF0a0B692e1c764281c211948D03edEeF5Fb57111;

  // Testnet Env
  address immutable TESTNET_PROXY_ADMIN = 0x246E71bC2a257f4BE9C7fAD4664E6D7444844Adc;
  address immutable TESTNET_OWNER = 0x4e070E9b85a659F0B7B47cde33152ad6c2F63954;
  address immutable TESTNET_GOERLI_ROOTS_OWNER = 0xa687922C4bf2eB22297FdF89156B49eD3727618b;
  address immutable TESTNET_MUMBAI_ROOTS_OWNER = 0xCA0583A6682607282963d3E2545Cd2e75697C2bb;

  // Sismo Staging env (Sismo internal use only)
  address immutable STAGING_PROXY_ADMIN = 0x246E71bC2a257f4BE9C7fAD4664E6D7444844Adc;
  address immutable STAGING_OWNER = 0x4e070E9b85a659F0B7B47cde33152ad6c2F63954;
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

  error ChainNotConfigured(DeployedChain chain);
  error ChainNameNotFound(string chainName);

  enum DeployedChain {
    Gnosis,
    Polygon,
    TestnetGoerli,
    TestnetMumbai,
    StagingGoerli,
    StagingMumbai,
    Test
  }

  function getChainName(string memory chainName) internal returns (DeployedChain) {
    if (_compareString(chainName, "gnosis")) {
      return DeployedChain.Gnosis;
    } else if (_compareString(chainName, "polygon")) {
      return DeployedChain.Polygon;
    } else if (_compareString(chainName, "testnet-goerli")) {
      return DeployedChain.TestnetGoerli;
    } else if (_compareString(chainName, "testnet-mumbai")) {
      return DeployedChain.TestnetMumbai;
    } else if (_compareString(chainName, "staging-goerli")) {
      return DeployedChain.StagingGoerli;
    } else if (_compareString(chainName, "staging-mumbai")) {
      return DeployedChain.StagingMumbai;
    } else if (_compareString(chainName, "test")) {
      return DeployedChain.Test;
    }
    revert ChainNameNotFound(chainName);
  }

  function _setConfig(DeployedChain chain) internal returns (DeploymentConfig memory) {
    if (chain == DeployedChain.Gnosis) {
      config = DeploymentConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_GNOSIS_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployedChain.Polygon) {
      config = DeploymentConfig({
        proxyAdmin: MAIN_PROXY_ADMIN,
        owner: MAIN_OWNER,
        rootsOwner: MAIN_POLYGON_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          PROD_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployedChain.TestnetGoerli) {
      config = DeploymentConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployedChain.TestnetMumbai) {
      config = DeploymentConfig({
        proxyAdmin: TESTNET_PROXY_ADMIN,
        owner: TESTNET_OWNER,
        rootsOwner: TESTNET_MUMBAI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployedChain.StagingGoerli) {
      config = DeploymentConfig({
        proxyAdmin: STAGING_PROXY_ADMIN,
        owner: STAGING_OWNER,
        rootsOwner: STAGING_GOERLI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployedChain.StagingMumbai) {
      config = DeploymentConfig({
        proxyAdmin: STAGING_PROXY_ADMIN,
        owner: STAGING_OWNER,
        rootsOwner: STAGING_MUMBAI_ROOTS_OWNER,
        commitmentMapperEdDSAPubKey: [
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_X,
          DEV_BETA_COMMITMENT_MAPPER_PUB_KEY_Y
        ]
      });
    } else if (chain == DeployedChain.Test) {
      config = DeploymentConfig({
        proxyAdmin: address(1),
        owner: address(2),
        rootsOwner: address(3),
        commitmentMapperEdDSAPubKey: [uint256(10), uint256(11)]
      });
    } else {
      revert ChainNotConfigured(chain);
    }
  }

  function _compareString(string memory a, string memory b) internal pure returns (bool) {
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
