// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "../verifiers/hydra-s2/HydraS2BaseTest.t.sol";
import "src/libs/zk-connect/ZkConnectLib.sol";

contract ZkConnectTest is HydraS2BaseTest {
    DataRequest dataRequest = DataRequestLib.build({groupId: 0xe9ed316946d3d98dfcd829a53ec9822e});

    bytes16 immutable appId = 0x112a692a2005259c25f6094161007967;
    ZkConnect zkConnect;

    function setUp() public virtual override {
        super.setUp();
        zkConnect = new ZkConnect(appId, address(addressesProvider));
    }

    function test_Revert_InvalidZkConnectResponse() public {
        bytes memory zkResponseEncoded = hex"";
        vm.expectRevert(abi.encodeWithSignature("ZkConnectResponseIsEmpty()"));
        zkConnect.verify(zkResponseEncoded, dataRequest);
    }

    function test_RevertWith_InvalidZkConnectVersion() public {
        ZkConnectResponse memory zkResponse = hydraS2Proofs.getZkConnectResponse1();
        zkResponse.version = bytes32("fake-version");
        bytes memory zkResponseEncoded = abi.encode(zkResponse);
        vm.expectRevert(
            abi.encodeWithSignature(
                "InvalidZkConnectVersion(bytes32,bytes32)",
                zkResponse.version,
                zkConnect.getZkConnectVersion()
            )
        );
        zkConnect.verify(zkResponseEncoded, dataRequest);
    }

    function test_ZkConnectLib() public {
        bytes memory zkResponseEncoded = hydraS2Proofs.getZkConnectResponse1AsBytes();
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = zkConnect.verify(zkResponseEncoded, dataRequest);

        console.log("zkConnectVerifiedResult.vaultId: %s", zkConnectVerifiedResult.vaultId);
    }
}
