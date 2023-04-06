// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

struct SismoConnectRequest {
  bytes16 appId;
  bytes16 namespace;
  AuthRequest[] authRequests;
	ClaimRequest[] claimRequests;
  SignatureRequest signatureRequest;
}

struct AuthRequest {
  AuthType authType;
  uint256 userId; // default: 0
  // flags
  bool isAnon; // default: false -> true not supported yet, need to throw if true
  bool isOptional; // default: false
  bool isSelectableByUser; // default: false
  // 
  bytes extraData; // default: ""
}

struct ClaimRequest {
  ClaimType claimType; // default: GTE
  bytes16 groupId;
  bytes16 groupTimestamp; // default: bytes16("latest")
  uint256 value; // default: 1
  // flags
  bool isOptional; // default: false 
  bool isSelectableByUser; // default: false
  // 
  bytes extraData; // default: ""
}

struct SignatureRequest {
  bytes message; // default: "MESSAGE_SELECTED_BY_USER"
  bool isSelectableByUser; // default: false
  bytes extraData; // default: ""
}

enum AuthType {
  VAULT,
  GITHUB,
  TWITTER,
  EVM_ACCOUNT
}

enum ClaimType {
  GTE,
  GT,
  EQ,
  LT,
  LTE
}

struct Auth {
  AuthType authType;
  bool isAnon;
  uint256 userId;
  bytes extraData;
}

struct Claim {
  ClaimType claimType;
  bytes16 groupId;
  bytes16 groupTimestamp;
  uint256 value;
  bytes extraData;
}

struct Signature {
  bytes message;
  bytes extraData;
}

struct SismoConnectResponse {
  bytes16 appId;
  bytes16 namespace;
  bytes32 version;
  bytes signedMessage;
  SismoConnectProof[] proofs;
}

struct SismoConnectProof {
  Auth[] auths;
  Claim[] claims;
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

struct VerifiedAuth {
  AuthType authType;
  bool isAnon;
  uint256 userId;
  bytes extraData;
  bytes proofData;
}

struct VerifiedClaim {
  ClaimType claimType;
  bytes16 groupId;
  bytes16 groupTimestamp;
  uint256 value;
  bytes extraData;
  uint256 proofId;
  bytes proofData;
}
