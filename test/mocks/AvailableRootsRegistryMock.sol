// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAvailableRootsRegistry} from "src/periphery/interfaces/IAvailableRootsRegistry.sol";

contract AvailableRootsRegistryMock is IAvailableRootsRegistry {
    mapping(uint256 => bool) public _roots;

    function initialize(address) external {}

    function isRootAvailableForMe(uint256 root) external view returns (bool) {
        return _roots[root];
    }

    function registerRootForAll(uint256 root) external {
        _roots[root] = true;
    }

    function unregisterRootForAll(uint256 root) external {
        _roots[root] = false;
    }

    function registerRootForAttester(address, uint256 root) external {
        _roots[root] = true;
    }

    function unregisterRootForAttester(address, uint256 root) external {
        _roots[root] = false;
    }

    function isRootAvailableForAttester(address, uint256 root) external view returns (bool) {
        return _roots[root];
    }
}
