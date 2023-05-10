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

    _setConfig(getChainName(chainName));

    availableRootsRegistry = _deployAvailableRootsRegistry(config.rootsOwner);
    commitmentMapperRegistry = _deployCommitmentMapperRegistry(
      config.owner,
      config.commitmentMapperEdDSAPubKey
    );
    hydraS2Verifier = _deployHydraS2Verifier(commitmentMapperRegistry, availableRootsRegistry);
    sismoConnectVerifier = _deploySismoConnectVerifier(msg.sender);

    sismoConnectVerifier.registerVerifier(
      hydraS2Verifier.HYDRA_S2_VERSION(),
      address(hydraS2Verifier)
    );
    sismoConnectVerifier.transferOwnership(config.owner);

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

    vm.stopBroadcast();
  }

  function _deployAvailableRootsRegistry(address owner) private returns (AvailableRootsRegistry) {
    if (config.availableRootsRegistry != address(0)) {
      console.log("Using existing availableRootsRegistry:", config.availableRootsRegistry);
      return AvailableRootsRegistry(config.availableRootsRegistry);
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
    if (config.commitmentMapperRegistry != address(0)) {
      console.log("Using existing commitmentMapperRegistry:", config.commitmentMapperRegistry);
      return CommitmentMapperRegistry(config.commitmentMapperRegistry);
    }
    CommitmentMapperRegistry commitmentMapperImplem = new CommitmentMapperRegistry(
      owner,
      commitmentMapperEdDSAPubKey
    );
    console.log("commitmentMapper Implem Deployed:", address(commitmentMapperImplem));

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

  function _deployHydraS2Verifier(
    CommitmentMapperRegistry _commitmentMapperRegistry,
    AvailableRootsRegistry _availableRootsRegistry
  ) private returns (HydraS2Verifier) {
    if (config.hydraS2Verifier != address(0)) {
      console.log("Using existing hydraS2Verifier:", config.hydraS2Verifier);
      return HydraS2Verifier(config.hydraS2Verifier);
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
      config.proxyAdmin,
      abi.encodeWithSelector(hydraS2VerifierImplem.initialize.selector)
    );
    console.log("hydraS2Verifier Proxy Deployed:", address(proxy));
    return HydraS2Verifier(address(proxy));
  }

  function _deploySismoConnectVerifier(address owner) private returns (SismoConnectVerifier) {
    if (config.sismoConnectVerifier != address(0)) {
      console.log("Using existing sismoConnectVerifier:", config.sismoConnectVerifier);
      return SismoConnectVerifier(config.sismoConnectVerifier);
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
    if (config.authRequestBuilder != address(0)) {
      console.log("Using existing authrequestBuilder:", config.authRequestBuilder);
      return AuthRequestBuilder(config.authRequestBuilder);
    }
    authRequestBuilder = new AuthRequestBuilder();
    console.log("authRequestBuilder Deployed:", address(authRequestBuilder));
    return authRequestBuilder;
  }

  function _deployClaimRequestBuilder() private returns (ClaimRequestBuilder) {
    if (config.claimRequestBuilder != address(0)) {
      console.log("Using existing claimRequestBuilder:", config.claimRequestBuilder);
      return ClaimRequestBuilder(config.claimRequestBuilder);
    }
    claimRequestBuilder = new ClaimRequestBuilder();
    console.log("claimRequestBuilder Deployed:", address(claimRequestBuilder));
    return claimRequestBuilder;
  }

  function _deploySignatureBuilder() private returns (SignatureBuilder) {
    if (config.signatureBuilder != address(0)) {
      console.log("Using existing signatureBuilder:", config.signatureBuilder);
      return SignatureBuilder(config.signatureBuilder);
    }
    signatureBuilder = new SignatureBuilder();
    console.log("signatureBuilder Deployed:", address(signatureBuilder));
    return signatureBuilder;
  }

  function _deployRequestBuilder() private returns (RequestBuilder) {
    if (config.requestBuilder != address(0)) {
      console.log("Using existing requestBuilder:", config.requestBuilder);
      return RequestBuilder(config.requestBuilder);
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
