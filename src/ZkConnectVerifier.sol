// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import "./libs/Struct.sol";
import "forge-std/console.sol";

contract ZkConnectVerifier {
    bytes32 immutable ZK_CONNECT_VERSION = "zk-connect-v1";

    mapping(bytes32 => IBaseVerifier) public _verifiers;

    error InvalidZKConnectVersion(bytes32 version);
    error InvalidNamespace(bytes16 namespace);
    error InvalidAppId(bytes16 appId);
    error ProvingSchemeNotSupported(bytes32 provingScheme);

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
            (vaultId, verifiedStatementFromProof) = _verifiers[proof.provingScheme].verify(appId, namespace, proof, destination);
            verifiedStatements[i] = verifiedStatementFromProof;
        }

        _checkVerifiedStatementsMatchDataRequest(verifiedStatements, dataRequest);

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
