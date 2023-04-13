// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./interfaces/ISismoConnectVerifier.sol";
import {AuthMatchingLib} from "./libs/sismo-connect/AuthMatchingLib.sol";
import {ClaimMatchingLib} from "./libs/sismo-connect/ClaimMatchingLib.sol";
import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract SismoConnectVerifier is ISismoConnectVerifier, Initializable, Ownable {
  using AuthMatchingLib for Auth;
  using ClaimMatchingLib for Claim;

  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable SISMO_CONNECT_VERSION = "sismo-connect-v1";

  mapping(bytes32 => IBaseVerifier) public _verifiers;

  // struct to store informations about the number of verified auths and claims returned
  // indexes of the first available slot in the arrays of auths and claims are also stored
  // this struct is used to avoid stack to deep errors without using via_ir in foundry
  struct VerifiedArraysInfos {
    uint256 nbOfAuths; // number of verified auths
    uint256 nbOfClaims; // number of verified claims
    uint256 authsIndex; // index of the first available slot in the array of verified auths
    uint256 claimsIndex; // index of the first available slot in the array of verified claims
  }

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

    uint256 responseProofsArrayLength = response.proofs.length;
    VerifiedArraysInfos memory infos = VerifiedArraysInfos({
      nbOfAuths: 0,
      nbOfClaims: 0,
      authsIndex: 0,
      claimsIndex: 0
    });

    // Count the number of auths and claims in the response
    for (uint256 i = 0; i < responseProofsArrayLength; i++) {
      infos.nbOfAuths += response.proofs[i].auths.length;
      infos.nbOfClaims += response.proofs[i].claims.length;
    }

    VerifiedAuth[] memory verifiedAuths = new VerifiedAuth[](infos.nbOfAuths);
    VerifiedClaim[] memory verifiedClaims = new VerifiedClaim[](infos.nbOfClaims);

    for (uint256 i = 0; i < responseProofsArrayLength; i++) {
      (VerifiedAuth memory verifiedAuth, VerifiedClaim memory verifiedClaim) = _verifiers[
        response.proofs[i].provingScheme
      ].verify({
          appId: response.appId,
          namespace: response.namespace,
          signedMessage: response.signedMessage,
          sismoConnectProof: response.proofs[i]
        });

      // we only want to add the verified auths and claims to the result
      // if they are not empty, for that we check the length of the proofData that should always be different from 0
      if (verifiedAuth.proofData.length != 0) {
        verifiedAuths[infos.authsIndex] = verifiedAuth;
        infos.authsIndex++;
      }
      if (verifiedClaim.proofData.length != 0) {
        verifiedClaims[infos.claimsIndex] = verifiedClaim;
        infos.claimsIndex++;
      }
    }

    return
      SismoConnectVerifiedResult({
        appId: response.appId,
        namespace: response.namespace,
        version: response.version,
        auths: verifiedAuths,
        claims: verifiedClaims,
        signedMessage: response.signedMessage
      });
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

    // Check if the message of the signature matches between the request and the response
    // if the signature request is NOT selectable by the user
    if (request.signature.isSelectableByUser == false) {
      // Check if the message signature matches between the request and the response
      // only if the content of the signature is different from the hash of "MESSAGE_SELECTED_BY_USER"
      if (
        keccak256(request.signature.message) != keccak256("MESSAGE_SELECTED_BY_USER") &&
        // we hash the messages to be able to compare them (as they are of type bytes)
        keccak256(request.signature.message) != keccak256(response.signedMessage)
      ) {
        revert SignatureMessageMismatch(request.signature.message, response.signedMessage);
      }
    }

    // we store the auths and claims in the response
    uint256 nbOfAuths = 0;
    uint256 nbOfClaims = 0;
    for (uint256 i = 0; i < response.proofs.length; i++) {
      nbOfAuths += response.proofs[i].auths.length;
      nbOfClaims += response.proofs[i].claims.length;
    }

    Auth[] memory authsInResponse = new Auth[](nbOfAuths);
    uint256 authsIndex = 0;
    Claim[] memory claimsInResponse = new Claim[](nbOfClaims);
    uint256 claimsIndex = 0;
    // we store the auths and claims in the response in a single respective array
    for (uint256 i = 0; i < response.proofs.length; i++) {
      // we do a loop on the proofs array and on the auths array of each proof
      for (uint256 j = 0; j < response.proofs[i].auths.length; j++) {
        authsInResponse[authsIndex] = response.proofs[i].auths[j];
        authsIndex++;
      }
      // we do a loop on the proofs array and on the claims array of each proof
      for (uint256 j = 0; j < response.proofs[i].claims.length; j++) {
        claimsInResponse[claimsIndex] = response.proofs[i].claims[j];
        claimsIndex++;
      }
    }

    // Check if the auths and claims in the request match the auths and claims int the response
    _checkAuthsInRequestMatchWithAuthsInResponse({
      authsInRequest: request.auths,
      authsInResponse: authsInResponse
    });
    _checkClaimsInRequestMatchWithClaimsInResponse({
      claimsInRequest: request.claims,
      claimsInResponse: claimsInResponse
    });
  }

  function _checkAuthsInRequestMatchWithAuthsInResponse(
    AuthRequest[] memory authsInRequest,
    Auth[] memory authsInResponse
  ) internal pure {
    // for each auth in the request, we check if it matches with one of the auths in the response
    for (uint256 i = 0; i < authsInRequest.length; i++) {
      AuthRequest memory authRequest = authsInRequest[i];
      if (authRequest.isOptional) {
        // if the auth in the request is optional, we consider that its properties are all matching
        // and we don't need to check for errors
        continue;
      }
      // we store the information about the maximum matching properties in a uint8
      // if the auth in the request matches with an auth in the response, the matchingProperties will be equal to 7 (111)
      // otherwise, we can look at the binary representation of the matchingProperties to know which properties are not matching and throw an error
      uint8 maxMatchingPropertiesLevel = 0;

      for (uint256 j = 0; j < authsInResponse.length; j++) {
        // we store the matching properties for the current auth in the response in a uint8
        // we will store it in the maxMatchingPropertiesLevel variable if it is greater than the current value of maxMatchingPropertiesLevel
        Auth memory auth = authsInResponse[j];
        uint8 matchingPropertiesLevel = auth._matchLevel(authRequest);

        // if the matchingPropertiesLevel are greater than the current value of maxMatchingPropertiesLevel, we update the value of maxMatchingPropertiesLevel
        // by doing so we will be able to know how close the auth in the request is to the auth in the response
        if (matchingPropertiesLevel > maxMatchingPropertiesLevel) {
          maxMatchingPropertiesLevel = matchingPropertiesLevel;
        }
      }
      AuthMatchingLib.handleAuthErrors(maxMatchingPropertiesLevel, authRequest);
    }
  }

  function _checkClaimsInRequestMatchWithClaimsInResponse(
    ClaimRequest[] memory claimsInRequest,
    Claim[] memory claimsInResponse
  ) internal pure {
    // for each claim in the request, we check if it matches with one of the claims in the response
    for (uint256 i = 0; i < claimsInRequest.length; i++) {
      ClaimRequest memory claimRequest = claimsInRequest[i];
      if (claimRequest.isOptional) {
        // if the claim in the request is optional, we consider that its properties are all matching
        continue;
      }
      // we store the information about the maximum matching properties in a uint8
      // if the claim in the request matches with a claim in the response, the matchingProperties will be equal to 7 (111)
      // otherwise, we can look at the binary representation of the matchingProperties to know which properties are not matching and throw an error
      uint8 maxMatchingProperties = 0;

      for (uint256 j = 0; j < claimsInResponse.length; j++) {
        Claim memory claim = claimsInResponse[j];
        uint8 matchingProperties = claim._matchLevel(claimRequest);

        // if the matchingProperties are greater than the current value of maxMatchingProperties, we update the value of maxMatchingProperties
        // by doing so we will be able to know how close the claim in the request is to the claim in the response
        if (matchingProperties > maxMatchingProperties) {
          maxMatchingProperties = matchingProperties;
        }
      }
      ClaimMatchingLib.handleClaimErrors(maxMatchingProperties, claimRequest);
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
