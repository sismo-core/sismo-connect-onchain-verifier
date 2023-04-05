// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

struct SismoConnectRequest {
  bytes16 appId;
  bytes16 namespace;
  Auth[] authRequests;
	Claim[] claimRequests;
  Signature signatureRequest;
  bytes32 version;
}

struct Auth {
  AuthType authType;
  bool isAnon;
  uint256 userId;
  bool isOptional;
  bool isSelectableByUser;
  bytes extraData;
}

struct Claim {
  bytes16 groupId;
  bytes16 groupTimestamp;
  uint256 value;
  ClaimType claimType;
  bool isOptional;
  bool isSelectableByUser;
  bytes extraData;
}

struct Signature {
  bytes content;
  bool isSelectableByUser;
  bytes extraData;
}


enum ClaimType {
  EMPTY,
  GTE,
  GT,
  EQ,
  LT,
  LTE,
  USER_SELECT
}

enum AuthType {
  EMPTY,
  ANON,
  GITHUB,
  TWITTER,
  EVM_ACCOUNT
}

enum LogicalOperator {
  AND,
  OR
}

struct SismoConnectResponse {
  bytes16 appId;
  bytes16 namespace;
  bytes32 version;
  SismoConnectProof[] proofs;
}

struct SismoConnectProof {
  Claim claim;
  Auth auth;
  bytes signedMessage;
  bytes32 provingScheme;
  bytes proofData;
  bytes extraData;
}

struct SismoConnectVerifiedResult {
  bytes16 appId;
  bytes16 namespace;
  bytes32 version;
  VerifiedAuth[] verifiedAuths;
  VerifiedClaim[] verifiedClaims;
  bytes signedMessage;
}

struct VerifiedClaim {
  bytes16 groupId;
  bytes16 groupTimestamp;
  uint256 value;
  ClaimType claimType;
  bool isOptional;
  bool isSelectableByUser;
  bytes extraData;
  uint256 proofId;
  bytes proofData;
}

struct VerifiedAuth {
  AuthType authType;
  bool isAnon;
  uint256 userId;
  bool isOptional;
  bool isSelectableByUser;
  bytes extraData;
  bytes proofData;
}
