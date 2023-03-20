// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAvailableRootsRegistry} from "./interfaces/IAvailableRootsRegistry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/**
 * @title Attesters Groups Registry
 * @author Sismo
 * @notice This contract stores that data required by attesters to be available so they can verify user claims
 * This contract is deployed behind a proxy and this implementation is focused on storing merkle roots
 * For more information: https://available-roots-registry.docs.sismo.io
 *
 *
 */
contract AvailableRootsRegistry is IAvailableRootsRegistry, Ownable {
    uint8 public constant IMPLEMENTATION_VERSION = 2;

    mapping(uint256 => bool) public _roots;

    /**
     * @dev Constructor
     * @param owner Owner of the contract, can register/ unregister roots
     */
    constructor(address owner) {
        _transferOwnership(owner);
    }

    /**
     * @dev Registers a root, available for all contracts
     * @param root Root to register
     */
    function registerRoot(uint256 root) external onlyOwner {
        _registerRoot(root);
    }

    /**
     * @dev Unregister a root, available for all contracts
     * @param root Root to unregister
     */
    function unregisterRoot(uint256 root) external onlyOwner {
        _unregisterRoot(root);
    }

    /**
     * @dev returns whether a root is available
     * @param root root to check whether it is registered for me or not
     */
    function isRootAvailable(uint256 root) external view returns (bool) {
        return _roots[root];
    }

    function _registerRoot(uint256 root) internal {
        _roots[root] = true;
        emit RegisteredRoot(root);
    }

    function _unregisterRoot(uint256 root) internal {
        _roots[root] = false;
        emit UnRegisteredRoot(root);
    }
}
