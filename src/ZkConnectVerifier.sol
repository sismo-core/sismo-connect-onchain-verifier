// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import "./libs/utils/Struct.sol";
import "forge-std/console.sol";

contract ZkConnectVerifier {
    bytes32 public immutable ZK_CONNECT_VERSION = "zk-connect-v1";

    mapping(bytes32 => IBaseVerifier) public _verifiers;

    error ProofsAndStatementRequestsAreUnequalInLength();
    error ProvingSchemeNotSupported(bytes32 provingScheme);
    error StatementRequestNotFound(bytes16 groupId, bytes16 groupTimestamp);
    error StatementComparatorMismatch(StatementComparator comparator, StatementComparator expectedComparator);
    error StatementExtraDataMismatch(bytes extraData, bytes expectedExtraData);
    error StatementProvingSchemeMismatch(bytes32 provingScheme, bytes32 expectedProvingScheme);
    error StatementValueMismatch(StatementComparator comparator, uint256 value, uint256 expectedValue);
    error AuthProofIsEmpty();

    event VerifierSet(bytes32, address);

    function verify(ZkConnectResponse memory zkConnectResponse, DataRequest memory dataRequest)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        uint256 vaultId = 0;
        bytes16 appId = zkConnectResponse.appId;
        bytes16 namespace = zkConnectResponse.namespace;
        bytes memory signedMessage = zkConnectResponse.signedMessage;

        if (zkConnectResponse.proofs.length != dataRequest.statementRequests.length) {
            revert ProofsAndStatementRequestsAreUnequalInLength();
        }

        if (zkConnectResponse.proofs.length == 0 && dataRequest.statementRequests.length == 0) {
            vaultId = _verifyAuthProof(appId, zkConnectResponse.authProof, zkConnectResponse.signedMessage);
            return ZkConnectVerifiedResult({
                appId: appId,
                namespace: namespace,
                version: zkConnectResponse.version,
                verifiedStatements: new VerifiedStatement[](0),
                signedMessage: signedMessage,
                vaultId: vaultId
            });
        }

        VerifiedStatement memory verifiedStatementFromProof;
        VerifiedStatement[] memory verifiedStatements = new VerifiedStatement[](zkConnectResponse.proofs.length);
        for (uint256 i = 0; i < zkConnectResponse.proofs.length; i++) {
            ZkConnectProof memory proof = zkConnectResponse.proofs[i];
            if (_verifiers[proof.provingScheme] == IBaseVerifier(address(0))) {
                revert ProvingSchemeNotSupported(proof.provingScheme);
            }
            _checkStatementMatchDataRequest(proof, dataRequest);
            (vaultId, verifiedStatementFromProof) =
                _verifiers[proof.provingScheme].verify(appId, namespace, proof, signedMessage);
            verifiedStatements[i] = verifiedStatementFromProof;
        }

        return ZkConnectVerifiedResult({
            appId: appId,
            namespace: namespace,
            version: zkConnectResponse.version,
            verifiedStatements: verifiedStatements,
            signedMessage: signedMessage,
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

    function _verifyAuthProof(bytes16 appId, AuthProof memory authProof, bytes memory signedMessage)
        internal
        returns (uint256 vaultId)
    {
        if (keccak256(authProof.proofData) == keccak256(bytes(""))) {
            revert AuthProofIsEmpty();
        }

        return _verifiers[authProof.provingScheme].verifyAuthProof(appId, authProof, signedMessage);
    }

    function _checkStatementMatchDataRequest(ZkConnectProof memory proof, DataRequest memory dataRequest) public pure {
        Statement memory statement = proof.statement;
        bytes16 groupId = statement.groupId;
        bytes16 groupTimestamp = statement.groupTimestamp;
        bytes32 provingScheme = proof.provingScheme;

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

        if (statement.comparator != statementRequest.comparator) {
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
