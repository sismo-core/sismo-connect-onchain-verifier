// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/**
 * @title IAvailableRootsRegistry
 * @author Sismo
 * @notice Interface for (Merkle) Roots Registry
 */
interface IAvailableRootsRegistry {
    event RegisteredRoot(uint256 root);
    event UnRegisteredRoot(uint256 root);

    /**
     * @dev Initializes the contract, to be called by the proxy delegating calls to this implementation
     * @param owner Owner of the contract, can update public key and address
     * @notice The reinitializer modifier is needed to configure modules that are added through upgrades and that require initialization.
     */
    function initialize(address owner) external;

    /**
     * @dev Registers a root, available for all contracts
     * @param root Root to register
     */
    function registerRoot(uint256 root) external;

    /**
     * @dev Unregister a root, available for all contracts
     * @param root Root to unregister
     */
    function unregisterRoot(uint256 root) external;

    /**
     * @dev returns whether a root is available for a caller (msg.sender)
     * @param root root to check whether it is registered for me or not
     */
    function isRootAvailable(uint256 root) external view returns (bool);
}
