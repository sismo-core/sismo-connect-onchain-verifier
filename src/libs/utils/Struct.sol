// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

struct ZkConnectRequestContent {
    DataRequest[] dataRequests;
    LogicalOperator[] operators;
}

struct DataRequest {
    Auth authRequest;
    Claim claimRequest;
    bytes messageSignatureRequest;
}

struct Claim {
    bytes16 groupId;
    bytes16 groupTimestamp;
    ClaimType claimType;
    uint256 value;
    bytes extraData;
    bool isValid;
}

struct Auth {
    AuthType authType;
    bool anonMode;
    uint256 userId;
    bytes extraData;
    bool isValid;
}

enum ClaimType {
    GTE,
    GT,
    EQ,
    LT,
    LTE,
    USER_SELECT
}

enum AuthType {
    NONE,
    ANON,
    GITHUB,
    TWITTER,
    EVM_ACCOUNT
}

enum LogicalOperator {
    AND,
    OR
}

struct ZkConnectResponse {
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
    ZkConnectProof[] proofs;
}

struct ZkConnectProof {
    Claim claim;
    Auth auth;
    bytes signedMessage;
    bytes32 provingScheme;
    bytes proofData;
    bytes extraData;
}

struct ZkConnectVerifiedResult {
    bytes16 appId;
    bytes16 namespace;
    bytes32 version;
    VerifiedClaim[] verifiedClaims;
    VerifiedAuth[] verifiedAuths;
    bytes[] signedMessages;
}

struct VerifiedClaim {
    bytes16 groupId;
    bytes16 groupTimestamp;
    ClaimType claimType;
    uint256 value;
    bytes extraData;
    uint256 proofId;
    bool isValid;
}

struct VerifiedAuth {
    AuthType authType;
    bool anonMode;
    uint256 userId;
    bytes extraData;
    uint256 proofId;
    bool isValid;
}
