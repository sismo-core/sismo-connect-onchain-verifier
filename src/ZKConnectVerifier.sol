// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import "./libs/Struct.sol";

contract ZKConnectVerifier {
    bytes32 immutable ZK_CONNECT_VERSION = "zk-connect-v1";

    mapping(bytes32 => IBaseVerifier) public _verifiers;

    error InvalidZKConnectVersion(bytes32 version);
    error InvalidNamespace(bytes16 namespace);
    error InvalidAppId(bytes16 appId);

    function verify(
        bytes16 appId,
        ZkConnectResponse memory zkConnectResponse,
        DataRequest memory dataRequest,
        bytes16 namespace
    ) public returns (ZkConnectVerifiedResult memory result) {
        if (zkConnectResponse.version != ZK_CONNECT_VERSION) {
            revert InvalidZKConnectVersion(zkConnectResponse.version);
        }
        if (zkConnectResponse.appId != appId) {
            revert InvalidAppId(zkConnectResponse.appId);
        }
        if (zkConnectResponse.namespace != namespace) {
            revert InvalidNamespace(zkConnectResponse.namespace);
        }

        ZkConnectProof[] memory proofs = new ZkConnectProof[](zkConnectResponse.proofs.length);

        uint256 vaultId = 0;
        // todo compute the total amount of verifiedStatements
        VerifiedStatement[] memory verifiedStatements = new VerifiedStatement[](3);
        for (uint256 i = 0; i < proofs.length; i++) {
            ZkConnectProof memory proof = proofs[i];
            Statement[] memory statements = proof.statements;
            VerifiedStatement[] memory verifiedStatementFromProof = new VerifiedStatement[](statements.length);

            (vaultId, verifiedStatementFromProof) = _verifiers[proof.provingScheme].verify(appId, namespace, proof);

            for (uint256 j = 0; j < verifiedStatementFromProof.length; j++) {
                verifiedStatements[i + j] = verifiedStatementFromProof[j];
            }
        }

        _checkVerifiedStatementsMatchDataRequest(verifiedStatements, dataRequest);

        return ZkConnectVerifiedResult({
            appId: appId,
            namespace: namespace,
            version: zkConnectResponse.version,
            verifiedStatements: verifiedStatements,
            vaultId: vaultId
        });
    }

    function _checkVerifiedStatementsMatchDataRequest(
        VerifiedStatement[] memory verifiedStatements,
        DataRequest memory dataRequest
    ) public {
        // Statement[] memory statements = proof.statements;
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
