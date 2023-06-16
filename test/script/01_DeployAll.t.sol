// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "script/01_DeployAll.s.sol";
import {DeployAvailableRootsRegistry} from "script/DeployAvailableRootsRegistry.s.sol";
import {DeployCommitmentMapperRegistry} from "script/DeployCommitmentMapperRegistry.s.sol";
import "script/BaseConfig.sol";

contract DeployAllTest is Test, BaseDeploymentConfig {
  ScriptTypes.DeployAllContracts contracts;

  address immutable PROXY_ADMIN = address(1);
  address immutable OWNER = address(2);
  address immutable ROOTS_OWNER = address(3);

  function setUp() public virtual {
    _chainName = "test";
    _checkIfEmpty = true;

    DeployAll deploy = new DeployAll();

    (bool success, bytes memory result) = address(deploy).delegatecall(
      abi.encodeWithSelector(DeployAll.runFor.selector, "test")
    );
    require(success, "Deploy script did not run successfully!");
    contracts = abi.decode(result, (ScriptTypes.DeployAllContracts));
  }

  function testAvailableRootsRegistryDeployed() public {
    _expectDeployedWithProxy(address(contracts.availableRootsRegistry), PROXY_ADMIN);
    assertEq(contracts.availableRootsRegistry.owner(), ROOTS_OWNER);
  }

  function testCommitmentMapperRegistryDeployed() public {
    _expectDeployedWithProxy(address(contracts.commitmentMapperRegistry), PROXY_ADMIN);
    assertEq(contracts.commitmentMapperRegistry.owner(), OWNER);
  }

  function testHydraS3Verifier() public {
    _expectDeployedWithProxy(address(contracts.hydraS3Verifier), PROXY_ADMIN);
    assertEq(
      address(contracts.hydraS3Verifier.COMMITMENT_MAPPER_REGISTRY()),
      address(contracts.commitmentMapperRegistry)
    );
    assertEq(
      address(contracts.hydraS3Verifier.AVAILABLE_ROOTS_REGISTRY()),
      address(contracts.availableRootsRegistry)
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
