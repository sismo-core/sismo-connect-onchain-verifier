// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import "./libs/utils/Struct.sol";
import "forge-std/console.sol";

contract ZkConnectVerifier {
    bytes32 public immutable ZK_CONNECT_VERSION = "zk-connect-v1";

    mapping(bytes32 => IBaseVerifier) public _verifiers;

    error ProofNeedsAuthOrClaim();
    error ProofsAndDataRequestsAreUnequalInLength(uint256 proofsLength, uint256 dataRequestsLength);
    error ProvingSchemeNotSupported(bytes32 provingScheme);
    error ClaimRequestNotFound(bytes16 groupId, bytes16 groupTimestamp);
    error ClaimTypeMismatch(ClaimType claimType, ClaimType expectedClaimType);
    error ClaimExtraDataMismatch(bytes extraData, bytes expectedExtraData);
    error ClaimProvingSchemeMismatch(bytes32 provingScheme, bytes32 expectedProvingScheme);
    error ClaimValueMismatch(ClaimType claimType, uint256 value, uint256 expectedValue);
    error AuthProofIsEmpty();

    event VerifierSet(bytes32, address);

    function verify(ZkConnectResponse memory zkConnectResponse, ZkConnectRequestContent memory zkConnectRequestContent)
        public
        returns (ZkConnectVerifiedResult memory)
    {
        bytes16 appId = zkConnectResponse.appId;
        bytes16 namespace = zkConnectResponse.namespace;

        uint256 proofsLength = zkConnectResponse.proofs.length;
        uint256 dataRequestsLength = zkConnectRequestContent.dataRequests.length;
        if (proofsLength != dataRequestsLength) {
            revert ProofsAndDataRequestsAreUnequalInLength(proofsLength, dataRequestsLength);
        }

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

            if (proof.auth.isValid == false && proof.claim.isValid == false) {
                revert ProofNeedsAuthOrClaim();
            }

            if (proof.auth.isValid) {
                verifiedAuth = _verifiers[proof.provingScheme].verifyAuthProof(appId, proof);
                verifiedAuths[i] = verifiedAuth;
            } else {
                VerifiedAuth memory emptyVerifiedAuth;
                verifiedAuths[i] = emptyVerifiedAuth;
            }

            if (proof.claim.isValid) {
                _checkClaimMatchDataRequest(proof, zkConnectRequestContent);
                verifiedClaim = _verifiers[proof.provingScheme].verifyClaim(appId, namespace, proof);
                verifiedClaims[i] = verifiedClaim;
            } else {
                VerifiedClaim memory emptyVerifiedClaim;
                verifiedClaims[i] = emptyVerifiedClaim;
            }

            signedMessages[i] = proof.signedMessage;
        }

        return ZkConnectVerifiedResult({
            appId: appId,
            namespace: namespace,
            version: zkConnectResponse.version,
            verifiedClaims: verifiedClaims,
            verifiedAuths: verifiedAuths,
            signedMessages: signedMessages
        });
    }

    function setVerifier(bytes32 provingScheme, address verifierAddress) public {
        _setVerifier(provingScheme, verifierAddress);
    }

    function _setVerifier(bytes32 provingScheme, address verifierAddress) internal {
        _verifiers[provingScheme] = IBaseVerifier(verifierAddress);
        emit VerifierSet(provingScheme, verifierAddress);
    }

    function _checkClaimMatchDataRequest(
        ZkConnectProof memory proof,
        ZkConnectRequestContent memory zkConnectRequestContent
    ) public pure {
        Claim memory claim = proof.claim;
        bytes16 groupId = claim.groupId;
        bytes16 groupTimestamp = claim.groupTimestamp;
        bytes32 provingScheme = proof.provingScheme;

        bool isClaimRequestFound = false;
        Claim memory claimRequest;
        for (uint256 i = 0; i < zkConnectRequestContent.dataRequests.length; i++) {
            claimRequest = zkConnectRequestContent.dataRequests[i].claimRequest;
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
}
