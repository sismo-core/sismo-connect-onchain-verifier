// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "src/periphery/AvailableRootsRegistry.sol";
import "src/periphery/CommitmentMapperRegistry.sol";
import {HydraS3Verifier} from "src/verifiers/HydraS3Verifier.sol";

import {SismoConnectVerifier} from "src/SismoConnectVerifier.sol";
import {AuthRequestBuilder} from "src/utils/AuthRequestBuilder.sol";
import {ClaimRequestBuilder} from "src/utils/ClaimRequestBuilder.sol";
import {SignatureBuilder} from "src/utils/SignatureBuilder.sol";
import {RequestBuilder} from "src/utils/RequestBuilder.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract DeployAll is Script, BaseDeploymentConfig {
  AvailableRootsRegistry availableRootsRegistry;
  CommitmentMapperRegistry commitmentMapperRegistry;
  HydraS3Verifier hydraS3Verifier;
  SismoConnectVerifier sismoConnectVerifier;

  // external libraries
  AuthRequestBuilder authRequestBuilder;
  ClaimRequestBuilder claimRequestBuilder;
  SignatureBuilder signatureBuilder;
  RequestBuilder requestBuilder;

  function runFor(
    string memory chainName
  ) public returns (ScriptTypes.DeployAllContracts memory contracts) {
    console.log("Run for CHAIN_NAME:", chainName);
    console.log("Deployer:", msg.sender);

    vm.startBroadcast();

    _setDeploymentConfig({chainName: chainName, checkIfEmpty: true});

    availableRootsRegistry = _deployAvailableRootsRegistry(config.rootsOwner);
    commitmentMapperRegistry = _deployCommitmentMapperRegistry(
      config.owner,
      config.commitmentMapperEdDSAPubKey
    );

    hydraS3Verifier = _deployHydraS3Verifier(
      address(commitmentMapperRegistry),
      address(availableRootsRegistry)
    );
    sismoConnectVerifier = _deploySismoConnectVerifier(msg.sender);

    sismoConnectVerifier.registerVerifier(
      hydraS3Verifier.HYDRA_S3_VERSION(),
      address(hydraS3Verifier)
    );

    sismoConnectVerifier.transferOwnership(config.owner);

    contracts.availableRootsRegistry = availableRootsRegistry;
    contracts.commitmentMapperRegistry = commitmentMapperRegistry;
    contracts.hydraS3Verifier = hydraS3Verifier;
    contracts.sismoConnectVerifier = sismoConnectVerifier;

    // external libraries

    authRequestBuilder = _deployAuthRequestBuilder();
    claimRequestBuilder = _deployClaimRequestBuilder();
    signatureBuilder = _deploySignatureBuilder();
    requestBuilder = _deployRequestBuilder();

    contracts.authRequestBuilder = authRequestBuilder;
    contracts.claimRequestBuilder = claimRequestBuilder;
    contracts.signatureBuilder = signatureBuilder;
    contracts.requestBuilder = requestBuilder;

    DeploymentConfig memory newDeploymentConfig = DeploymentConfig({
      proxyAdmin: config.proxyAdmin,
      owner: config.owner,
      rootsOwner: config.rootsOwner,
      commitmentMapperEdDSAPubKey: config.commitmentMapperEdDSAPubKey,
      sismoAddressesProviderV2: config.sismoAddressesProviderV2,
      availableRootsRegistry: address(availableRootsRegistry),
      commitmentMapperRegistry: address(commitmentMapperRegistry),
      hydraS3Verifier: address(hydraS3Verifier),
      sismoConnectVerifier: address(sismoConnectVerifier),
      authRequestBuilder: address(authRequestBuilder),
      claimRequestBuilder: address(claimRequestBuilder),
      signatureBuilder: address(signatureBuilder),
      requestBuilder: address(requestBuilder)
    });

    _saveDeploymentConfig(chainName, newDeploymentConfig);

    vm.stopBroadcast();
  }

  function _deployAvailableRootsRegistry(address owner) private returns (AvailableRootsRegistry) {
    address availableRootsRegistryAddress = config.availableRootsRegistry;
    if (availableRootsRegistryAddress != address(0)) {
      console.log("Using existing availableRootsRegistry:", availableRootsRegistryAddress);
      return AvailableRootsRegistry(availableRootsRegistryAddress);
    }
    AvailableRootsRegistry rootsRegistryImplem = new AvailableRootsRegistry(owner);
    console.log("rootsRegistry Implem Deployed:", address(rootsRegistryImplem));

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(rootsRegistryImplem),
      config.proxyAdmin,
      abi.encodeWithSelector(rootsRegistryImplem.initialize.selector, owner)
    );
    console.log("rootsRegistry Proxy Deployed:", address(proxy));
    return AvailableRootsRegistry(address(proxy));
  }

  function _deployCommitmentMapperRegistry(
    address owner,
    uint256[2] memory commitmentMapperEdDSAPubKey
  ) private returns (CommitmentMapperRegistry) {
    address commitmentMapperRegistryAddress = config.commitmentMapperRegistry;
    if (commitmentMapperRegistryAddress != address(0)) {
      console.log("Using existing commitmentMapperRegistry:", commitmentMapperRegistryAddress);
      return CommitmentMapperRegistry(commitmentMapperRegistryAddress);
    }
    CommitmentMapperRegistry commitmentMapperImplem = new CommitmentMapperRegistry(
      owner,
      commitmentMapperEdDSAPubKey
    );
    console.log("commitmentMapper Implem Deployed:", address(commitmentMapperImplem));
    console.log("owner:", owner);

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(commitmentMapperImplem),
      config.proxyAdmin,
      abi.encodeWithSelector(
        commitmentMapperImplem.initialize.selector,
        owner,
        commitmentMapperEdDSAPubKey
      )
    );
    console.log("commitmentMapper Proxy Deployed:", address(proxy));
    return CommitmentMapperRegistry(address(proxy));
  }

  function _deployHydraS3Verifier(
    address commitmentMapperRegistryAddr,
    address availableRootsRegistryAddr
  ) private returns (HydraS3Verifier) {
    address hydraS3VerifierAddress = config.hydraS3Verifier;
    if (hydraS3VerifierAddress != address(0)) {
      console.log("Using existing hydraS3Verifier:", hydraS3VerifierAddress);
      return HydraS3Verifier(hydraS3VerifierAddress);
    }
    HydraS3Verifier hydraS3VerifierImplem = new HydraS3Verifier(
      commitmentMapperRegistryAddr,
      availableRootsRegistryAddr
    );
    console.log("hydraS3Verifier Implem Deployed:", address(hydraS3VerifierImplem));

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(hydraS3VerifierImplem),
      config.proxyAdmin,
      abi.encodeWithSelector(hydraS3VerifierImplem.initialize.selector)
    );
    console.log("hydraS3Verifier Proxy Deployed:", address(proxy));
    return HydraS3Verifier(address(proxy));
  }

  function _deploySismoConnectVerifier(address owner) private returns (SismoConnectVerifier) {
    address sismoConnectVerifierAddress = config.sismoConnectVerifier;
    if (sismoConnectVerifierAddress != address(0)) {
      console.log("Using existing sismoConnectVerifier:", sismoConnectVerifierAddress);
      return SismoConnectVerifier(sismoConnectVerifierAddress);
    }
    SismoConnectVerifier sismoConnectVerifierImplem = new SismoConnectVerifier(owner);
    console.log("sismoConnectVerifier Implem Deployed:", address(sismoConnectVerifierImplem));

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(sismoConnectVerifierImplem),
      config.proxyAdmin,
      abi.encodeWithSelector(sismoConnectVerifierImplem.initialize.selector, owner)
    );
    console.log("sismoConnectVerifier Proxy Deployed:", address(proxy));
    return SismoConnectVerifier(address(proxy));
  }

  // External libraries

  function _deployAuthRequestBuilder() private returns (AuthRequestBuilder) {
    address authRequestBuilderAddress = config.authRequestBuilder;
    if (authRequestBuilderAddress != address(0)) {
      console.log("Using existing authrequestBuilder:", authRequestBuilderAddress);
      return AuthRequestBuilder(authRequestBuilderAddress);
    }
    authRequestBuilder = new AuthRequestBuilder();
    console.log("authRequestBuilder Deployed:", address(authRequestBuilder));
    return authRequestBuilder;
  }

  function _deployClaimRequestBuilder() private returns (ClaimRequestBuilder) {
    address claimRequestBuilderAddress = config.claimRequestBuilder;
    if (claimRequestBuilderAddress != address(0)) {
      console.log("Using existing claimRequestBuilder:", claimRequestBuilderAddress);
      return ClaimRequestBuilder(claimRequestBuilderAddress);
    }
    claimRequestBuilder = new ClaimRequestBuilder();
    console.log("claimRequestBuilder Deployed:", address(claimRequestBuilder));
    return claimRequestBuilder;
  }

  function _deploySignatureBuilder() private returns (SignatureBuilder) {
    address signatureBuilderAddress = config.signatureBuilder;
    if (signatureBuilderAddress != address(0)) {
      console.log("Using existing signatureBuilder:", signatureBuilderAddress);
      return SignatureBuilder(signatureBuilderAddress);
    }
    signatureBuilder = new SignatureBuilder();
    console.log("signatureBuilder Deployed:", address(signatureBuilder));
    return signatureBuilder;
  }

  function _deployRequestBuilder() private returns (RequestBuilder) {
    address requestBuilderAddress = config.requestBuilder;
    if (requestBuilderAddress != address(0)) {
      console.log("Using existing requestBuilder:", requestBuilderAddress);
      return RequestBuilder(requestBuilderAddress);
    }
    requestBuilder = new RequestBuilder();
    console.log("requestBuilder Deployed:", address(requestBuilder));
    return requestBuilder;
  }

  function run() public returns (ScriptTypes.DeployAllContracts memory contracts) {
    string memory chainName = vm.envString("CHAIN_NAME");
    return runFor(chainName);
  }

  function deploymentConfigFilePath() external view returns (string memory) {
    return _deploymentConfigFilePath();
  }
}

library ScriptTypes {
  struct DeployAllContracts {
    AvailableRootsRegistry availableRootsRegistry;
    CommitmentMapperRegistry commitmentMapperRegistry;
    HydraS3Verifier hydraS3Verifier;
    SismoConnectVerifier sismoConnectVerifier;
    // external libraries
    AuthRequestBuilder authRequestBuilder;
    ClaimRequestBuilder claimRequestBuilder;
    SignatureBuilder signatureBuilder;
    RequestBuilder requestBuilder;
  }
}
