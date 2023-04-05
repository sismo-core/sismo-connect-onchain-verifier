// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./interfaces/ISismoConnectVerifier.sol";
import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SismoConnectVerifier is ISismoConnectVerifier, Initializable, Ownable {
  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable SISMO_CONNECT_VERSION = "sismo-connect-v1";

  mapping(bytes32 => IBaseVerifier) public _verifiers;

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
    SismoConnectResponse memory response,
    SismoConnectRequest memory request
  ) external view override returns (SismoConnectVerifiedResult memory) {
    _checkResponseMatchesWithRequest(response, request);

    (
      VerifiedAuth memory verifiedAuth,
      VerifiedClaim memory verifiedClaim,
      bytes memory signedMessage
    ) = _verifiers[response.proofs[0].provingScheme].verify({
        appId: response.appId,
        namespace: response.namespace,
        sismoConnectProof: response.proofs[0]
      });

    VerifiedAuth[] memory verifiedAuths = new VerifiedAuth[](1);
    verifiedAuths[0] = verifiedAuth;
    VerifiedClaim[] memory verifiedClaims = new VerifiedClaim[](1);
    verifiedClaims[0] = verifiedClaim;

    return
      SismoConnectVerifiedResult(
        response.appId,
        response.namespace,
        response.version,
        verifiedAuths,
        verifiedClaims,
        signedMessage
      );
  }

  function _checkResponseMatchesWithRequest(
    SismoConnectResponse memory response,
    SismoConnectRequest memory request
  ) internal view {
    if (response.version != SISMO_CONNECT_VERSION) {
      revert VersionMismatch(response.version, SISMO_CONNECT_VERSION);
    }

    if (response.namespace != request.namespace) {
      revert NamespaceMismatch(response.namespace, request.namespace);
    }

    if (response.appId != request.appId) {
      revert AppIdMismatch(response.appId, request.appId);
    }

    // Get the first proof and the first auth and claim
    // TODO: support multiple proofs, multiple auths and multiple claims for aggregation
    SismoConnectProof memory proof = response.proofs[0];
    Auth memory authRequest = request.authRequests[0];
    Claim memory claimRequest = request.claimRequests[0];

    // Check if the message signature matches between the request and the response
    // only if the content of the signature is different from the hash of "MESSAGE_SELECTED_BY_USER"
    if (
      keccak256(request.signatureRequest.content) != keccak256("MESSAGE_SELECTED_BY_USER") &&
      keccak256(request.signatureRequest.content) != keccak256(proof.signedMessage)
    ) {
      revert MessageSignatureMismatch(request.signatureRequest.content, proof.signedMessage);
    }

    _checkAuthResponseMatchesWithAuthRequest(proof.auth, authRequest);
    _checkClaimResponseMatchesWithClaimRequest(proof.claim, claimRequest);
  }

  function _checkAuthResponseMatchesWithAuthRequest(
    Auth memory authResponse,
    Auth memory authRequest
  ) internal pure {
    if (authResponse.authType != authRequest.authType) {
      revert AuthTypeMismatch(authResponse.authType, authRequest.authType);
    }
    if (authResponse.isAnon != authRequest.isAnon) {
      revert AuthAnonModeMismatch(authResponse.isAnon, authRequest.isAnon);
    }
    if (authResponse.userId != authRequest.userId) {
      revert AuthUserIdMismatch(authResponse.userId, authRequest.userId);
    }
    if (keccak256(authResponse.extraData) != keccak256(authRequest.extraData)) {
      revert AuthExtraDataMismatch(authResponse.extraData, authRequest.extraData);
    }
  }

  function _checkClaimResponseMatchesWithClaimRequest(
    Claim memory claimResponse,
    Claim memory claimRequest
  ) internal pure {
    if (claimResponse.claimType != claimRequest.claimType) {
      revert ClaimTypeMismatch(claimResponse.claimType, claimRequest.claimType);
    }
    if (claimResponse.groupId != claimRequest.groupId) {
      revert ClaimGroupIdMismatch(claimResponse.groupId, claimRequest.groupId);
    }
    if (claimResponse.groupTimestamp != claimRequest.groupTimestamp) {
      revert ClaimGroupTimestampMismatch(claimResponse.groupTimestamp, claimRequest.groupTimestamp);
    }
    if (claimResponse.value != claimRequest.value) {
      revert ClaimValueMismatch(claimResponse.value, claimRequest.value);
    }
    if (keccak256(claimResponse.extraData) != keccak256(claimRequest.extraData)) {
      revert ClaimExtraDataMismatch(claimResponse.extraData, claimRequest.extraData);
    }
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
}
