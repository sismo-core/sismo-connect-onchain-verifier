// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/libs/utils/Struct.sol";
import "src/libs/utils/DataRequestLib.sol";
import "src/libs/utils/StatementRequestLib.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ZkConnectVerifier} from "src/ZkConnectVerifier.sol";
import {IAddressesProvider} from "src/periphery/interfaces/IAddressesProvider.sol";

contract ZkConnect is Context {
    uint256 public constant ZK_CONNECT_LIB_VERSION = 1;

    IAddressesProvider public immutable ADDRESSES_PROVIDER =
        IAddressesProvider(0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05);

    ZkConnectVerifier private _zkConnectVerifier;
    bytes16 public appId;

    error ZkConnectResponseIsEmpty();
    error InvalidZkConnectVersion(bytes32 receivedVersion, bytes32 expectedVersion);
    error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
    error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);

    constructor(bytes16 _appId) {
        appId = _appId;
        _zkConnectVerifier = ZkConnectVerifier(ADDRESSES_PROVIDER.get(string("zkConnectVerifier")));
    }

    function verify(bytes memory zkConnectResponseEncoded, DataRequest memory dataRequest, bytes16 namespace)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        if (zkConnectResponseEncoded.length == 0) {
            revert ZkConnectResponseIsEmpty();
        }
        ZkConnectResponse memory zkConnectResponse = abi.decode(zkConnectResponseEncoded, (ZkConnectResponse));

        return verify(zkConnectResponse, dataRequest, namespace);
    }

    function verify(bytes memory zkConnectResponseEncoded, DataRequest memory dataRequest)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        return verify(zkConnectResponseEncoded, dataRequest, bytes16(keccak256("main")));
    }

    function verify(bytes memory zkConnectResponseEncoded) public returns (ZkConnectVerifiedResult memory) {
        return verify(
            zkConnectResponseEncoded,
            DataRequest({statementRequests: new StatementRequest[](0), operator: LogicalOperator.AND})
        );
    }

    function verify(ZkConnectResponse memory zkConnectResponse, DataRequest memory dataRequest, bytes16 namespace)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        if (zkConnectResponse.version != _zkConnectVerifier.ZK_CONNECT_VERSION()) {
            revert InvalidZkConnectVersion(zkConnectResponse.version, _zkConnectVerifier.ZK_CONNECT_VERSION());
        }

        if (zkConnectResponse.appId != appId) {
            revert AppIdMismatch(zkConnectResponse.appId, appId);
        }

        if (zkConnectResponse.namespace != namespace) {
            revert NamespaceMismatch(zkConnectResponse.namespace, namespace);
        }

        return _zkConnectVerifier.verify(zkConnectResponse, dataRequest);
    }

    function verify(ZkConnectResponse memory zkConnectResponse, DataRequest memory dataRequest)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        return verify(zkConnectResponse, dataRequest, bytes16(keccak256("main")));
    }

    function verify(ZkConnectResponse memory zkConnectResponse) public returns (ZkConnectVerifiedResult memory) {
        return verify(
            zkConnectResponse,
            DataRequest({statementRequests: new StatementRequest[](0), operator: LogicalOperator.AND})
        );
    }

    function getZkConnectVersion() public view returns (bytes32) {
        return _zkConnectVerifier.ZK_CONNECT_VERSION();
    }
}
