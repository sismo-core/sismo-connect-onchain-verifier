// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

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
}

struct Auth {
    AuthType authType;
    bool anonMode;
    uint256 userId;
    bytes extraData;
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
    ZkConnectProof[] proofs;
    Claim[] verifiedClaims;
    Auth[] verifiedAuths;
    bytes signedMessage;
}

struct VerifiedClaim {
    bytes16 groupId;
    bytes16 groupTimestamp;
    ClaimType claimType;
    uint256 value;
    bytes extraData;
    uint256 proofId;
}

struct VerifiedAuth {
    AuthType authType;
    bool anonMode;
    uint256 userId;
    bytes extraData;
    uint256 proofId;
}
