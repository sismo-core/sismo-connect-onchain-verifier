// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "script/01_DeployAll.s.sol";
import "script/DeployAvailableRootsRegistry.s.sol";
import "script/DeployCommitmentMapperRegistry.s.sol";
import "script/BaseConfig.sol";

contract DeployAllTest is Test, BaseDeploymentConfig {
  ScriptTypes.DeployAllContracts contracts;
  AvailableRootsRegistry availableRootsRegistry;
  CommitmentMapperRegistry commitmentMapperRegistry;

  address immutable PROXY_ADMIN = address(1);
  address immutable OWNER = address(2);
  address immutable ROOTS_OWNER = address(3);

  function setUp() public virtual {
    _chainName = "test";
    _checkIfEmpty = true;

    // Deploy AvailableRootsRegistry
    DeployAvailableRootsRegistry deployAvailableRootsRegistry = new DeployAvailableRootsRegistry();
    (
      bool deployAvailableRootsRegistrySuccess,
      bytes memory deployAvailableRootsRegistryResult
    ) = address(deployAvailableRootsRegistry).delegatecall(
        abi.encodeWithSelector(DeployAvailableRootsRegistry.runFor.selector, "test")
      );
    require(
      deployAvailableRootsRegistrySuccess,
      "DeployAvailableRootsRegistry script did not run successfully!"
    );
    availableRootsRegistry = abi.decode(
      deployAvailableRootsRegistryResult,
      (AvailableRootsRegistry)
    );

    // Deploy CommitmentMapperRegistry
    DeployCommitmentMapperRegistry deployCommitmentMapperRegistry = new DeployCommitmentMapperRegistry();
    (
      bool deployCommitmentMapperRegistrySuccess,
      bytes memory deployCommitmentMapperRegistryResult
    ) = address(deployCommitmentMapperRegistry).delegatecall(
        abi.encodeWithSelector(DeployCommitmentMapperRegistry.runFor.selector, "test")
      );
    require(
      deployCommitmentMapperRegistrySuccess,
      "DeployCommitmentMapperRegistry script did not run successfully!"
    );
    commitmentMapperRegistry = abi.decode(
      deployCommitmentMapperRegistryResult,
      (CommitmentMapperRegistry)
    );

    // Deploy Sismo Connect contracts
    DeployAll deploy = new DeployAll();

    (bool success, bytes memory result) = address(deploy).delegatecall(
      abi.encodeWithSelector(DeployAll.runFor.selector, "test")
    );
    require(success, "Deploy script did not run successfully!");
    contracts = abi.decode(result, (ScriptTypes.DeployAllContracts));
  }

  function testHydraS3Verifier() public {
    _expectDeployedWithProxy(address(contracts.hydraS3Verifier), PROXY_ADMIN);
    assertEq(
      address(contracts.hydraS3Verifier.COMMITMENT_MAPPER_REGISTRY()),
      address(commitmentMapperRegistry)
    );
    assertEq(
      address(contracts.hydraS3Verifier.AVAILABLE_ROOTS_REGISTRY()),
      address(availableRootsRegistry)
    );
  }

  function testSismoConnectVerifier() public {
    _expectDeployedWithProxy(address(contracts.sismoConnectVerifier), PROXY_ADMIN);
    assertEq(
      contracts.sismoConnectVerifier.getVerifier("hydra-s3.1"),
      address(contracts.hydraS3Verifier)
    );
    assertEq(contracts.sismoConnectVerifier.owner(), OWNER);
  }

  function test_RemoveFile() public {
    removeFile();
  }

  function _expectDeployedWithProxy(address proxy, address expectedAdmin) internal {
    // Expect proxy is deployed behin a TransparentUpgradeableProxy proxy with the right admin
    vm.prank(expectedAdmin);
    (bool success, bytes memory result) = address(proxy).call(
      abi.encodeWithSelector(TransparentUpgradeableProxy.admin.selector)
    );
    assertEq(success, true);
    assertEq(abi.decode(result, (address)), PROXY_ADMIN);
  }

  function removeFile() internal {
    console.log("Removing deploymentConfigFilePath", _deploymentConfigFilePath());

    vm.removeFile(_deploymentConfigFilePath());
  }
}
