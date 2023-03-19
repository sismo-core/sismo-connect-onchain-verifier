// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

struct ZkConnectRequest {
    DataRequest dataRequest;
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
}

struct DataRequest {
    StatementRequest[] statementRequests;
    LogicalOperator operator;
}

struct StatementRequest {
    bytes16 groupId;
    bytes16 groupTimestamp;
    uint256 requestedValue;
    StatementComparator comparator;
    bytes32 provingScheme;
    bytes extraData;
}

enum StatementComparator {
    GTE,
    GT,
    EQ,
    LT,
    LTE
}

enum LogicalOperator {
    AND,
    OR
}

struct VerifiableStatement {
    bytes16 groupId;
    bytes16 groupTimestamp;
    uint256 requestedValue;
    StatementComparator comparator;
    bytes32 provingScheme;
    bytes extraData;
    uint256 value;
    bytes proof;
}

struct VerifiedStatement {
    bytes16 groupId;
    bytes16 groupTimestamp;
    uint256 requestedValue;
    StatementComparator comparator;
    bytes32 provingScheme;
    bytes extraData;
    uint256 value;
    bytes proof;
    uint256 proofId;
}

struct ZkConnectResponse {
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
    bytes authProof;
    VerifiableStatement[] verifiableStatements;
}

struct ZkConnectVerifiedResult {
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
    uint256 vaultId;
    VerifiedStatement[] verifiedStatements;
}
