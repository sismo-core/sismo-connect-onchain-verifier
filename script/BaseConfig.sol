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

    address immutable TESTNET_ADMIN = 0xF61CabBa1e6FC166A66bcA0fcaa83762EdB6D4Bd;
    address immutable TESTNET_OWNER = 0x9424ac301cFe394db459136Acd299763AF6a0eF1;
    address immutable TESTNET_ROOTS_OWNER = 0x9424ac301cFe394db459136Acd299763AF6a0eF1;

    uint256 immutable DEV_COMMITMENT_MAPPER_PUB_KEY_X =
        0x2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f0256;
    uint256 immutable DEV_COMMITMENT_MAPPER_PUB_KEY_Y =
        0x30423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74;

    error ChainNotConfigured(Chains chain);

    enum Chains {
        Test,
        LocalGoerli,
        StagingGoerli,
        TestnetGoerli
    }

    function _setConfig(Chains chain) internal returns (DeploymentConfig memory) {
        if (chain == Chains.TestnetGoerli) {
            config = DeploymentConfig({
                proxyAdmin: TESTNET_ADMIN,
                owner: TESTNET_OWNER,
                rootsOwner: TESTNET_ROOTS_OWNER,
                // Dev commitment mapper pubkey
                commitmentMapperEdDSAPubKey: [DEV_COMMITMENT_MAPPER_PUB_KEY_X, DEV_COMMITMENT_MAPPER_PUB_KEY_Y]
            });
        } else if (chain == Chains.Test) {
            config = DeploymentConfig({
                proxyAdmin: TESTNET_ADMIN,
                owner: TESTNET_OWNER,
                rootsOwner: TESTNET_ROOTS_OWNER,
                // Dev commitment mapper pubkey
                commitmentMapperEdDSAPubKey: [DEV_COMMITMENT_MAPPER_PUB_KEY_X, DEV_COMMITMENT_MAPPER_PUB_KEY_Y]
            });
        } else {
            revert ChainNotConfigured(chain);
        }
    }

    /// @dev broadcast transaction modifier
    /// @param pk private key to broadcast transaction
    modifier broadcast(uint256 pk) {
        vm.startBroadcast(pk);

        _;

        vm.stopBroadcast();
    }
}
