// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import "./libs/utils/Struct.sol";
import "forge-std/console.sol";

contract ZkConnectVerifier {
    bytes32 immutable ZK_CONNECT_VERSION = "zk-connect-v1";

    mapping(bytes32 => IBaseVerifier) public _verifiers;

    error InvalidZKConnectVersion(bytes32 version);
    error InvalidNamespace(bytes16 namespace);
    error InvalidAppId(bytes16 appId);
    error ProvingSchemeNotSupported(bytes32 provingScheme);
    error StatementRequestNotFound(bytes16 groupId, bytes16 groupTimestamp);
    error StatementComparatorMismatch(StatementComparator comparator, StatementComparator expectedComparator);
    error StatementValueMismatch(StatementComparator comparator, uint256 value, uint256 expectedValue);
    error StatementExtraDataMismatch(bytes extraData, bytes expectedExtraData);

    event VerifierSet(bytes32, address);

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

        uint256 vaultId = 0;
        address destination = zkConnectResponse.destination;
        VerifiedStatement memory verifiedStatementFromProof;
        // todo compute the total amount of verifiedStatements
        VerifiedStatement[] memory verifiedStatements = new VerifiedStatement[](zkConnectResponse.proofs.length);
        for (uint256 i = 0; i < zkConnectResponse.proofs.length; i++) {
            ZkConnectProof memory proof = zkConnectResponse.proofs[i];
            if (_verifiers[proof.provingScheme] == IBaseVerifier(address(0))) {
                revert ProvingSchemeNotSupported(proof.provingScheme);
            }
            _checkStatementMatchDataRequest(proof.statement, dataRequest);
            (vaultId, verifiedStatementFromProof) = _verifiers[proof.provingScheme].verify(appId, namespace, proof, destination);
            verifiedStatements[i] = verifiedStatementFromProof;
        }

        return ZkConnectVerifiedResult({
            appId: appId,
            namespace: namespace,
            version: zkConnectResponse.version,
            verifiedStatements: verifiedStatements,
            destination: destination,
            vaultId: vaultId
        });
    }

    function setVerifier(bytes32 provingScheme, address verifierAddress) public {
        _setVerifier(provingScheme, verifierAddress);
    }

    function _setVerifier(bytes32 provingScheme, address verifierAddress) internal {
        _verifiers[provingScheme] = IBaseVerifier(verifierAddress);
        emit VerifierSet(provingScheme, verifierAddress);
    }

    function _checkStatementMatchDataRequest(
        Statement memory statement,
        DataRequest memory dataRequest
    ) public pure {
        bytes16 groupId = statement.groupId;
        bytes16 groupTimestamp = statement.groupTimestamp;

        bool isStatementRequestFound = false;
        StatementRequest memory statementRequest;
        for (uint256 i = 0; i < dataRequest.statementRequests.length; i++) {
            statementRequest = dataRequest.statementRequests[i];
            if (statementRequest.groupId == groupId && statementRequest.groupTimestamp == groupTimestamp) {
                isStatementRequestFound = true;
            }
        }

        if (!isStatementRequestFound) {
            revert StatementRequestNotFound(groupId, groupTimestamp);
        }

        if (statement.comparator != statementRequest.comparator ) {
            revert StatementComparatorMismatch(statement.comparator, statementRequest.comparator);
        }

        if (keccak256(statement.extraData) != keccak256(statementRequest.extraData)) {
            revert StatementExtraDataMismatch(statement.extraData, statementRequest.extraData);
        }

        if (statement.comparator == StatementComparator.EQ) {
            if (statement.value != statementRequest.requestedValue) {
                revert StatementValueMismatch(statement.comparator, statement.value, statementRequest.requestedValue);
            }
        }

        if (statement.comparator == StatementComparator.GT) {
            if (statement.value <= statementRequest.requestedValue) {
                revert StatementValueMismatch(statement.comparator, statement.value, statementRequest.requestedValue);
            }
        }

        if (statement.comparator == StatementComparator.GTE) {
            if (statement.value < statementRequest.requestedValue) {
                revert StatementValueMismatch(statement.comparator, statement.value, statementRequest.requestedValue);
            }
        }

        if (statement.comparator == StatementComparator.LT) {
            if (statement.value >= statementRequest.requestedValue) {
                revert StatementValueMismatch(statement.comparator, statement.value, statementRequest.requestedValue);
            }
        }

        if (statement.comparator == StatementComparator.LTE) {
            if (statement.value > statementRequest.requestedValue) {
                revert StatementValueMismatch(statement.comparator, statement.value, statementRequest.requestedValue);
            }
        }
    }
}
