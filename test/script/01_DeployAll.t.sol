// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

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
        console.log(success);
        console.logBytes(result);
        require(success, "Deploy script did not run successfully!");
        contracts = abi.decode(result, (ScriptTypes.DeployAllContracts));
    }

    function testDeployment() public {
        console.log(address(contracts.availableRootsRegistry));
    }

    // function testProxyIsInitializedWithRightAdmin() public {}
}
