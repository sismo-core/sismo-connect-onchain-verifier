// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/libs/utils/Struct.sol";
import "src/libs/utils/ZkConnectRequestContentLib.sol";
import {ClaimRequestLib} from "src/libs/utils/ClaimRequestLib.sol";
import {AuthRequestLib} from "src/libs/utils/AuthRequestLib.sol";
import {DataRequestLib} from "src/libs/utils/DataRequestLib.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IZkConnectVerifier} from "src/interfaces/IZkConnectVerifier.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract ZkConnect is Context {
    uint256 public constant ZK_CONNECT_LIB_VERSION = 1;

    IAddressesProvider public immutable ADDRESSES_PROVIDER =
        IAddressesProvider(0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05);

    IZkConnectVerifier private _zkConnectVerifier;
    bytes16 public appId;

    error ZkConnectResponseIsEmpty();
    error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
    error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);

    constructor(bytes16 _appId) {
        appId = _appId;
        _zkConnectVerifier = IZkConnectVerifier(ADDRESSES_PROVIDER.get(string("zkConnectVerifier")));
    }

    function verify(
        bytes memory zkConnectResponseEncoded,
        ZkConnectRequestContent memory zkConnectRequestContent,
        bytes16 namespace
    ) public returns (ZkConnectVerifiedResult memory) {
        if (zkConnectResponseEncoded.length == 0) {
            revert ZkConnectResponseIsEmpty();
        }
        ZkConnectResponse memory zkConnectResponse = abi.decode(zkConnectResponseEncoded, (ZkConnectResponse));
        return verify(zkConnectResponse, zkConnectRequestContent, namespace);
    }

    function verify(bytes memory zkConnectResponseEncoded, ZkConnectRequestContent memory zkConnectRequestContent)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        return verify(zkConnectResponseEncoded, zkConnectRequestContent, bytes16(keccak256("main")));
    }

    function verify(bytes memory zkConnectResponseEncoded) public returns (ZkConnectVerifiedResult memory) {
        ZkConnectRequestContent memory zkConnectRequestContent;
        return verify(zkConnectResponseEncoded, zkConnectRequestContent, bytes16(keccak256("main")));
    }

    function verify(
        ZkConnectResponse memory zkConnectResponse,
        ZkConnectRequestContent memory zkConnectRequestContent,
        bytes16 namespace
    ) public returns (ZkConnectVerifiedResult memory) {
        if (zkConnectResponse.appId != appId) {
            revert AppIdMismatch(zkConnectResponse.appId, appId);
        }

        if (zkConnectResponse.namespace != namespace) {
            revert NamespaceMismatch(zkConnectResponse.namespace, namespace);
        }
        return _zkConnectVerifier.verify(zkConnectResponse, zkConnectRequestContent);
    }

    function getZkConnectVersion() public view returns (bytes32) {
        return _zkConnectVerifier.ZK_CONNECT_VERSION();
    }
}
