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

struct Statement {
    bytes16 groupId;
    bytes16 groupTimestamp;
    uint256 value;
    bytes extraData;
    StatementComparator comparator;
}

struct ZkConnectProof {
    Statement[] statements;
    bytes32 provingScheme;
    bytes proofData;
    bytes extraData;
}

struct VerifiedStatement {
    bytes16 groupId;
    bytes16 groupTimestamp;
    uint256 value;
    StatementComparator comparator;
    bytes32 provingScheme;
    uint256 proofId;
    bytes extraData;
}

struct ZkConnectResponse {
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
    ZkConnectProof[] proofs;
}

struct ZkConnectVerifiedResult {
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
    uint256 vaultId;
    VerifiedStatement[] verifiedStatements;
}
