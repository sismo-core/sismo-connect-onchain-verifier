// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import "./libs/Struct.sol";

contract ZKConnectVerifier {
    bytes32 immutable ZK_CONNECT_VERSION = "zk-connect-v1";

    mapping(bytes32 => IBaseVerifier) public _verifiers;

    error InvalidZKConnectVersion(bytes32 version);
    error InvalidNamespace(bytes32 namespace);

    function verify(ZkConnectResponse memory zkConnectResponse, DataRequest memory dataRequest, bytes16 namespace)
        public
        returns (ZkConnectVerifiedResult memory result)
    {
        if (zkConnectResponse.version != ZK_CONNECT_VERSION) {
            revert InvalidZKConnectVersion(zkConnectResponse.version);
        }
        if (zkConnectResponse.namespace != namespace) {
            revert InvalidNamespace(zkConnectResponse.namespace);
        }

        VerifiedStatement[] memory verifiedStatements =
            new VerifiedStatement[](zkConnectResponse.verifiableStatements.length);

        uint256 vaultId = 0;
        for (uint256 i = 0; i < zkConnectResponse.verifiableStatements.length; i++) {
            VerifiableStatement memory statement = zkConnectResponse.verifiableStatements[i];
            _checkVerifiableStatementMatchesDataRequest(statement, dataRequest);
            (vaultId, verifiedStatements[i]) =
                _verifyProof(zkConnectResponse.appId, zkConnectResponse.namespace, statement);
        }

        return ZkConnectVerifiedResult({
            appId: zkConnectResponse.appId,
            namespace: zkConnectResponse.namespace,
            version: zkConnectResponse.version,
            verifiedStatements: verifiedStatements,
            vaultId: vaultId
        });
    }

    function _verifyProof(bytes16 appId, bytes16 namespace, VerifiableStatement memory statement)
        public
        returns (uint256, VerifiedStatement memory)
    {
        (uint256 vaultId, uint256 proofId) = _verifiers[statement.provingScheme].verify(appId, namespace, statement);
        return (
            vaultId,
            VerifiedStatement({
                groupId: statement.groupId,
                groupTimestamp: statement.groupTimestamp,
                requestedValue: statement.requestedValue,
                comparator: statement.comparator,
                provingScheme: statement.provingScheme,
                extraData: statement.extraData,
                value: statement.value,
                proof: statement.proof,
                proofId: proofId
            })
        );
    }

    function _checkVerifiableStatementMatchesDataRequest(
        VerifiableStatement memory statement,
        DataRequest memory dataRequest
    ) public {
        // if (statement.groupId != request.groupId) {
        //     return false;
        // }
        // if (statement.groupTimestamp != request.groupTimestamp) {
        //     return false;
        // }
        // if (statement.requestedValue != request.requestedValue) {
        //     return false;
        // }
        // if (statement.comparator != request.comparator) {
        //     return false;
        // }
        // if (statement.provingScheme != request.provingScheme) {
        //     return false;
        // }
        // if (statement.extraData != request.extraData) {
        //     return false;
        // }

        // if (statement.comparator == StatementComparator.GTE) {
        //     return statement.value >= statement.requestedValue;
        // } else if (statement.comparator == StatementComparator.GT) {
        //     return statement.value > statement.requestedValue;
        // } else if (statement.comparator == StatementComparator.EQ) {
        //     return statement.value == statement.requestedValue;
        // } else if (statement.comparator == StatementComparator.LT) {
        //     return statement.value < statement.requestedValue;
        // } else if (statement.comparator == StatementComparator.LTE) {
        //     return statement.value <= statement.requestedValue;
        // } else {
        //     return false;
        // }
    }
}
