// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "script/01_DeployAll.s.sol";

contract DeployAllTest is Test {
    ScriptTypes.DeployAllContracts contracts;

    address immutable ADMIN = 0xF61CabBa1e6FC166A66bcA0fcaa83762EdB6D4Bd;
    address immutable OWNER = 0x9424ac301cFe394db459136Acd299763AF6a0eF1;
    address immutable ROOTS_OWNER = 0x9424ac301cFe394db459136Acd299763AF6a0eF1;

    function setUp() public virtual {
        DeployAll deploy = new DeployAll();

        (bool success, bytes memory result) =
            address(deploy).delegatecall(abi.encodeWithSelector(DeployAll.run.selector));
        require(success, "Deploy script did not run successfully!");
        contracts = abi.decode(result, (ScriptTypes.DeployAllContracts));
    }

    function testDeployment() public {
        console.log(address(contracts.availableRootsRegistry));
    }

    function testAvailableRootsRegistryDeployed() public {
        _expectDeployedWithProxy(address(contracts.availableRootsRegistry), ADMIN);
        assertEq(contracts.availableRootsRegistry.owner(), ROOTS_OWNER);
    }

    function testCommitmentMapperRegistryDeployed() public {
        _expectDeployedWithProxy(address(contracts.commitmentMapperRegistry), ADMIN);
        assertEq(contracts.commitmentMapperRegistry.owner(), OWNER);
    }

    function testHydraS2Verifier() public {
        _expectDeployedWithProxy(address(contracts.hydraS2Verifier), ADMIN);
        assertEq(
            address(contracts.hydraS2Verifier.COMMITMENT_MAPPER_REGISTRY()), address(contracts.commitmentMapperRegistry)
        );
        assertEq(
            address(contracts.hydraS2Verifier.AVAILABLE_ROOTS_REGISTRY()), address(contracts.availableRootsRegistry)
        );
    }

    function testZkConnectVerifier() public {
        _expectDeployedWithProxy(address(contracts.zkConnectVerifier), ADMIN);
        assertEq(contracts.zkConnectVerifier.getVerifier("hydra-s2.1"), address(contracts.hydraS2Verifier));
        assertEq(contracts.zkConnectVerifier.owner(), OWNER);
    }

    function _expectDeployedWithProxy(address proxy, address expectedAdmin) internal {
        // Expect proxy is deployed behin a TransparentUpgradeableProxy proxy with the right admin
        vm.prank(expectedAdmin);
        (bool success, bytes memory result) =
            address(proxy).call(abi.encodeWithSelector(TransparentUpgradeableProxy.admin.selector));
        assertEq(success, true);
        assertEq(abi.decode(result, (address)), ADMIN);
    }
}
