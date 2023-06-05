// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "src/periphery/AvailableRootsRegistry.sol";
import "src/periphery/CommitmentMapperRegistry.sol";
import {HydraS2Verifier} from "src/verifiers/HydraS2Verifier.sol";

import {SismoConnectVerifier} from "src/SismoConnectVerifier.sol";
import {AuthRequestBuilder} from "src/libs/utils/AuthRequestBuilder.sol";
import {ClaimRequestBuilder} from "src/libs/utils/ClaimRequestBuilder.sol";
import {SignatureBuilder} from "src/libs/utils/SignatureBuilder.sol";
import {RequestBuilder} from "src/libs/utils/RequestBuilder.sol";
import {DeploymentConfig, BaseDeploymentConfig} from "script/BaseConfig.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract DeployAll is Script, BaseDeploymentConfig {
  AvailableRootsRegistry availableRootsRegistry;
  CommitmentMapperRegistry commitmentMapperRegistry;
  HydraS2Verifier hydraS2Verifier;
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

    _setDeploymentConfig(chainName);

    availableRootsRegistry = _deployAvailableRootsRegistry(
      _readAddressFromDeploymentConfigAtKey(".rootsOwner")
    );
    commitmentMapperRegistry = _deployCommitmentMapperRegistry(
      _readAddressFromDeploymentConfigAtKey(".owner"),
      _readCommitmentMapperEdDSAPubKeyFromDeploymentConfig()
    );
    hydraS2Verifier = _deployHydraS2Verifier(commitmentMapperRegistry, availableRootsRegistry);
    sismoConnectVerifier = _deploySismoConnectVerifier(msg.sender);

    sismoConnectVerifier.registerVerifier(
      hydraS2Verifier.HYDRA_S2_VERSION(),
      address(hydraS2Verifier)
    );

    sismoConnectVerifier.transferOwnership(_readAddressFromDeploymentConfigAtKey(".owner"));

    contracts.availableRootsRegistry = availableRootsRegistry;
    contracts.commitmentMapperRegistry = commitmentMapperRegistry;
    contracts.hydraS2Verifier = hydraS2Verifier;
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
      proxyAdmin: _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      owner: _readAddressFromDeploymentConfigAtKey(".owner"),
      rootsOwner: _readAddressFromDeploymentConfigAtKey(".rootsOwner"),
      commitmentMapperEdDSAPubKey: _readCommitmentMapperEdDSAPubKeyFromDeploymentConfig(),
      sismoAddressesProvider: _readAddressFromDeploymentConfigAtKey(".sismoAddressesProvider"),
      availableRootsRegistry: address(availableRootsRegistry),
      commitmentMapperRegistry: address(commitmentMapperRegistry),
      hydraS2Verifier: address(hydraS2Verifier),
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
    address availableRootsRegistryAddress = _readAddressFromDeploymentConfigAtKey(
      ".availableRootsRegistry"
    );
    if (availableRootsRegistryAddress != address(0)) {
      console.log("Using existing availableRootsRegistry:", availableRootsRegistryAddress);
      return AvailableRootsRegistry(availableRootsRegistryAddress);
    }
    AvailableRootsRegistry rootsRegistryImplem = new AvailableRootsRegistry(owner);
    console.log("rootsRegistry Implem Deployed:", address(rootsRegistryImplem));

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(rootsRegistryImplem),
      _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      abi.encodeWithSelector(rootsRegistryImplem.initialize.selector, owner)
    );
    console.log("rootsRegistry Proxy Deployed:", address(proxy));
    return AvailableRootsRegistry(address(proxy));
  }

  function _deployCommitmentMapperRegistry(
    address owner,
    uint256[2] memory commitmentMapperEdDSAPubKey
  ) private returns (CommitmentMapperRegistry) {
    address commitmentMapperRegistryAddress = _readAddressFromDeploymentConfigAtKey(
      ".commitmentMapperRegistry"
    );
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
      _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      abi.encodeWithSelector(
        commitmentMapperImplem.initialize.selector,
        owner,
        commitmentMapperEdDSAPubKey
      )
    );
    console.log("commitmentMapper Proxy Deployed:", address(proxy));
    return CommitmentMapperRegistry(address(proxy));
  }

  function _deployHydraS2Verifier(
    CommitmentMapperRegistry _commitmentMapperRegistry,
    AvailableRootsRegistry _availableRootsRegistry
  ) private returns (HydraS2Verifier) {
    address hydraS2VerifierAddress = _readAddressFromDeploymentConfigAtKey(".hydraS2Verifier");
    if (hydraS2VerifierAddress != address(0)) {
      console.log("Using existing hydraS2Verifier:", hydraS2VerifierAddress);
      return HydraS2Verifier(hydraS2VerifierAddress);
    }
    address commitmentMapperRegistryAddr = address(_commitmentMapperRegistry);
    address availableRootsRegistryAddr = address(_availableRootsRegistry);
    HydraS2Verifier hydraS2VerifierImplem = new HydraS2Verifier(
      commitmentMapperRegistryAddr,
      availableRootsRegistryAddr
    );
    console.log("hydraS2Verifier Implem Deployed:", address(hydraS2VerifierImplem));

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(hydraS2VerifierImplem),
      _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      abi.encodeWithSelector(hydraS2VerifierImplem.initialize.selector)
    );
    console.log("hydraS2Verifier Proxy Deployed:", address(proxy));
    return HydraS2Verifier(address(proxy));
  }

  function _deploySismoConnectVerifier(address owner) private returns (SismoConnectVerifier) {
    address sismoConnectVerifierAddress = _readAddressFromDeploymentConfigAtKey(
      ".sismoConnectVerifier"
    );
    if (sismoConnectVerifierAddress != address(0)) {
      console.log("Using existing sismoConnectVerifier:", sismoConnectVerifierAddress);
      return SismoConnectVerifier(sismoConnectVerifierAddress);
    }
    SismoConnectVerifier sismoConnectVerifierImplem = new SismoConnectVerifier(owner);
    console.log("sismoConnectVerifier Implem Deployed:", address(sismoConnectVerifierImplem));

    TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
      address(sismoConnectVerifierImplem),
      _readAddressFromDeploymentConfigAtKey(".proxyAdmin"),
      abi.encodeWithSelector(sismoConnectVerifierImplem.initialize.selector, owner)
    );
    console.log("sismoConnectVerifier Proxy Deployed:", address(proxy));
    return SismoConnectVerifier(address(proxy));
  }

  // External libraries

  function _deployAuthRequestBuilder() private returns (AuthRequestBuilder) {
    address authRequestBuilderAddress = _readAddressFromDeploymentConfigAtKey(
      ".authRequestBuilder"
    );
    if (authRequestBuilderAddress != address(0)) {
      console.log("Using existing authrequestBuilder:", authRequestBuilderAddress);
      return AuthRequestBuilder(authRequestBuilderAddress);
    }
    authRequestBuilder = new AuthRequestBuilder();
    console.log("authRequestBuilder Deployed:", address(authRequestBuilder));
    return authRequestBuilder;
  }

  function _deployClaimRequestBuilder() private returns (ClaimRequestBuilder) {
    address claimRequestBuilderAddress = _readAddressFromDeploymentConfigAtKey(
      ".claimRequestBuilder"
    );
    if (claimRequestBuilderAddress != address(0)) {
      console.log("Using existing claimRequestBuilder:", claimRequestBuilderAddress);
      return ClaimRequestBuilder(claimRequestBuilderAddress);
    }
    claimRequestBuilder = new ClaimRequestBuilder();
    console.log("claimRequestBuilder Deployed:", address(claimRequestBuilder));
    return claimRequestBuilder;
  }

  function _deploySignatureBuilder() private returns (SignatureBuilder) {
    address signatureBuilderAddress = _readAddressFromDeploymentConfigAtKey(".signatureBuilder");
    if (signatureBuilderAddress != address(0)) {
      console.log("Using existing signatureBuilder:", signatureBuilderAddress);
      return SignatureBuilder(signatureBuilderAddress);
    }
    signatureBuilder = new SignatureBuilder();
    console.log("signatureBuilder Deployed:", address(signatureBuilder));
    return signatureBuilder;
  }

  function _deployRequestBuilder() private returns (RequestBuilder) {
    address requestBuilderAddress = _readAddressFromDeploymentConfigAtKey(".requestBuilder");
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
}

library ScriptTypes {
  struct DeployAllContracts {
    AvailableRootsRegistry availableRootsRegistry;
    CommitmentMapperRegistry commitmentMapperRegistry;
    HydraS2Verifier hydraS2Verifier;
    SismoConnectVerifier sismoConnectVerifier;
    // external libraries
    AuthRequestBuilder authRequestBuilder;
    ClaimRequestBuilder claimRequestBuilder;
    SignatureBuilder signatureBuilder;
    RequestBuilder requestBuilder;
  }
}
