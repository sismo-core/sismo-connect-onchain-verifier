// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IZkConnectVerifier} from "./interfaces/IZkConnectVerifier.sol";
import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./libs/utils/Structs.sol";

contract ZkConnectVerifier is Initializable, Ownable {
  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable ZK_CONNECT_VERSION = "zk-connect-v2";

  mapping(bytes32 => IBaseVerifier) public _verifiers;

  error InvalidZkConnectVersion(bytes32 receivedVersion, bytes32 expectedVersion);
  error ProofNeedsAuthOrClaim();
  error ProofsAndDataRequestsAreUnequalInLength(uint256 proofsLength, uint256 dataRequestsLength);
  error OnlyOneProofSupportedWithLogicalOperatorOR();
  error ProvingSchemeNotSupported(bytes32 provingScheme);
  error ClaimRequestNotFound(bytes16 groupId, bytes16 groupTimestamp);
  error ClaimTypeMismatch(ClaimType claimType, ClaimType expectedClaimType);
  error ClaimExtraDataMismatch(bytes extraData, bytes expectedExtraData);
  error ClaimProvingSchemeMismatch(bytes32 provingScheme, bytes32 expectedProvingScheme);
  error ClaimValueMismatch(ClaimType claimType, uint256 value, uint256 expectedValue);
  error AuthProofIsEmpty();
  error AuthRequestNotFound(AuthType authType, bool anonMode);
  error AuthUserIdMismatch(uint256 userId, uint256 expectedUserId);

  event VerifierSet(bytes32, address);

  constructor(address owner) {
    initialize(owner);
  }

  function initialize(address ownerAddress) public reinitializer(IMPLEMENTATION_VERSION) {
    // if proxy did not setup owner yet or if called by constructor (for implem setup)
    if (owner() == address(0) || address(this).code.length == 0) {
      _transferOwnership(ownerAddress);
    }
  }

  function verify(
    ZkConnectResponse memory zkConnectResponse,
    ZkConnectRequest memory zkConnectRequest
  ) public returns (ZkConnectVerifiedResult memory) {
    if (zkConnectResponse.version != ZK_CONNECT_VERSION) {
      revert InvalidZkConnectVersion(zkConnectResponse.version, ZK_CONNECT_VERSION);
    }

    bytes16 appId = zkConnectResponse.appId;
    bytes16 namespace = zkConnectResponse.namespace;
    uint256 proofsLength = zkConnectResponse.proofs.length;

    _checkLogicalOperators(zkConnectResponse, zkConnectRequest);

    VerifiedClaim memory verifiedClaim;
    VerifiedAuth memory verifiedAuth;
    VerifiedClaim[] memory verifiedClaims = new VerifiedClaim[](proofsLength);
    VerifiedAuth[] memory verifiedAuths = new VerifiedAuth[](proofsLength);
    bytes[] memory signedMessages = new bytes[](proofsLength);

    for (uint256 i = 0; i < proofsLength; i++) {
      ZkConnectProof memory proof = zkConnectResponse.proofs[i];
      if (_verifiers[proof.provingScheme] == IBaseVerifier(address(0))) {
        revert ProvingSchemeNotSupported(proof.provingScheme);
      }

      if (proof.auth.authType == AuthType.EMPTY && proof.claim.claimType == ClaimType.EMPTY) {
        revert ProofNeedsAuthOrClaim();
      }

      if (proof.auth.authType != AuthType.EMPTY) {
        _checkAuthMatchContentRequest(proof, zkConnectRequest);
        verifiedAuth = _verifiers[proof.provingScheme].verifyAuthProof(appId, proof);
        verifiedAuths[i] = verifiedAuth;
      } else {
        VerifiedAuth memory emptyVerifiedAuth;
        verifiedAuths[i] = emptyVerifiedAuth;
      }

      if (proof.claim.claimType != ClaimType.EMPTY) {
        _checkClaimMatchContentRequest(proof, zkConnectRequest);
        verifiedClaim = _verifiers[proof.provingScheme].verifyClaim(appId, namespace, proof);
        verifiedClaims[i] = verifiedClaim;
      } else {
        VerifiedClaim memory emptyVerifiedClaim;
        verifiedClaims[i] = emptyVerifiedClaim;
      }

      signedMessages[i] = proof.signedMessage;
    }

    return
      ZkConnectVerifiedResult({
        appId: appId,
        namespace: namespace,
        version: zkConnectResponse.version,
        verifiedClaims: verifiedClaims,
        verifiedAuths: verifiedAuths,
        signedMessages: signedMessages
      });
  }

  function registerVerifier(bytes32 provingScheme, address verifierAddress) public onlyOwner {
    _setVerifier(provingScheme, verifierAddress);
  }

  function getVerifier(bytes32 provingScheme) public view returns (address) {
    return address(_verifiers[provingScheme]);
  }

  function _setVerifier(bytes32 provingScheme, address verifierAddress) internal {
    _verifiers[provingScheme] = IBaseVerifier(verifierAddress);
    emit VerifierSet(provingScheme, verifierAddress);
  }

  function _checkClaimMatchContentRequest(
    ZkConnectProof memory proof,
    ZkConnectRequest memory zkConnectRequest
  ) public pure {
    Claim memory claim = proof.claim;
    bytes16 groupId = claim.groupId;
    bytes16 groupTimestamp = claim.groupTimestamp;

    bool isClaimRequestFound = false;
    Claim memory claimRequest;
    for (uint256 i = 0; i < zkConnectRequest.content.dataRequests.length; i++) {
      claimRequest = zkConnectRequest.content.dataRequests[i].claimRequest;
      if (claimRequest.groupId == groupId && claimRequest.groupTimestamp == groupTimestamp) {
        isClaimRequestFound = true;
      }
    }

    if (!isClaimRequestFound) {
      revert ClaimRequestNotFound(groupId, groupTimestamp);
    }

    if (claim.claimType != claimRequest.claimType) {
      revert ClaimTypeMismatch(claim.claimType, claimRequest.claimType);
    }

    if (keccak256(claim.extraData) != keccak256(claimRequest.extraData)) {
      revert ClaimExtraDataMismatch(claim.extraData, claimRequest.extraData);
    }

    if (claim.claimType == ClaimType.EQ) {
      if (claim.value != claimRequest.value) {
        revert ClaimValueMismatch(claim.claimType, claim.value, claimRequest.value);
      }
    }

    if (claim.claimType == ClaimType.GT) {
      if (claim.value <= claimRequest.value) {
        revert ClaimValueMismatch(claim.claimType, claim.value, claimRequest.value);
      }
    }

    if (claim.claimType == ClaimType.GTE) {
      if (claim.value < claimRequest.value) {
        revert ClaimValueMismatch(claim.claimType, claim.value, claimRequest.value);
      }
    }

    if (claim.claimType == ClaimType.LT) {
      if (claim.value >= claimRequest.value) {
        revert ClaimValueMismatch(claim.claimType, claim.value, claimRequest.value);
      }
    }

    if (claim.claimType == ClaimType.LTE) {
      if (claim.value > claimRequest.value) {
        revert ClaimValueMismatch(claim.claimType, claim.value, claimRequest.value);
      }
    }
  }

  function _checkAuthMatchContentRequest(
    ZkConnectProof memory proof,
    ZkConnectRequest memory zkConnectRequest
  ) public pure {
    // extract the auth from the proof
    Auth memory auth = proof.auth;
    AuthType authType = auth.authType;
    bool anonMode = auth.anonMode;

    bool isAuthRequestFound = false;
    Auth memory authRequest;
    // check if the auth is found in the content request
    for (uint256 i = 0; i < zkConnectRequest.content.dataRequests.length; i++) {
      authRequest = zkConnectRequest.content.dataRequests[i].authRequest;
      if ((authRequest.authType == authType) && (authRequest.anonMode == anonMode)) {
        isAuthRequestFound = true;
      }
    }

    if (!isAuthRequestFound) {
      revert AuthRequestNotFound(authType, anonMode);
    }

    if (auth.userId != 0) {
      if (auth.userId != authRequest.userId) {
        revert AuthUserIdMismatch(auth.userId, authRequest.userId);
      }
    }

    if (keccak256(auth.extraData) != keccak256(authRequest.extraData)) {
      revert ClaimExtraDataMismatch(auth.extraData, authRequest.extraData);
    }
  }

  function _checkLogicalOperators(
    ZkConnectResponse memory zkConnectResponse,
    ZkConnectRequest memory zkConnectRequest
  ) public pure {
    // if the logical operator is AND, the number of proofs should be equal to the number of data requests
    if (zkConnectRequest.content.operators[0] == LogicalOperator.AND) {
      if (zkConnectResponse.proofs.length != zkConnectRequest.content.dataRequests.length) {
        revert ProofsAndDataRequestsAreUnequalInLength(
          zkConnectResponse.proofs.length,
          zkConnectRequest.content.dataRequests.length
        );
      }
    }
    // if the logical operator is OR, the number of proofs should be 1
    if (zkConnectRequest.content.operators[0] == LogicalOperator.OR) {
      if (zkConnectResponse.proofs.length != 1) {
        revert OnlyOneProofSupportedWithLogicalOperatorOR();
      }
    }
  }
}
