// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "./interfaces/ISismoConnectVerifier.sol";
import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SismoConnectError} from "./libs/sismo-connect/SismoConnectError.sol";

contract SismoConnectVerifier is ISismoConnectVerifier, Initializable, Ownable {
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
      revert SismoConnectError.VersionMismatch(response.version, SISMO_CONNECT_VERSION);
    }

    if (response.namespace != request.namespace) {
      revert SismoConnectError.NamespaceMismatch(response.namespace, request.namespace);
    }

    if (response.appId != request.appId) {
      revert SismoConnectError.AppIdMismatch(response.appId, request.appId);
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
        revert SismoConnectError.SignatureMessageMismatch(
          request.signature.message,
          response.signedMessage
        );
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
      // we store the information about the maximum matching properties in a uint8
      // if the auth in the request matches with an auth in the response, the matchingProperties will be equal to 15 (1111)
      // otherwise, we can look at the binary representation of the matchingProperties to know which properties are not matching and throw an error
      uint8 maxMatchingProperties = 0;
      AuthRequest memory authRequest = authsInRequest[i];

      for (uint256 j = 0; j < authsInResponse.length; j++) {
        // we store the matching properties for the current auth in the response in a uint8
        // we will store it in the maxMatchingProperties variable if it is greater than the current value of maxMatchingProperties
        uint8 matchingProperties = 0;
        Auth memory auth = authsInResponse[j];
        if (auth.authType == authRequest.authType) {
          matchingProperties += 1; // 001
        }
        if (auth.isAnon == authRequest.isAnon) {
          matchingProperties += 2; // 010
        }

        if (authRequest.authType == AuthType.VAULT) {
          // If authType is Vault the user can't choose a particular userId
          // It will be always defined as userId = Hash(VaultSecret, AppId)
          // There is then no specific constraint on the isSelectableByUser and userId properties)
          matchingProperties += 4; // 100
        } else if (authRequest.isSelectableByUser == false && auth.userId == authRequest.userId) {
          // if the userId in the auth request can NOT be chosen by the user when generating the proof (isSelectableByUser == true)
          // we check if the userId of the auth in the request matches the userId of the auth in the response
          matchingProperties += 4; // 100
        } else if (authRequest.isSelectableByUser == true) {
          // if the userId in the auth request can be chosen by the user when generating the proof (isSelectableByUser == true)
          // we dont check if the userId of the auth in the request matches the userId of the auth in the response
          // the property is considered as matching
          matchingProperties += 4; // 100
        }
        // if the matchingProperties are greater than the current value of maxMatchingProperties, we update the value of maxMatchingProperties
        // by doing so we will be able to know how close the auth in the request is to the auth in the response
        if (matchingProperties > maxMatchingProperties) {
          maxMatchingProperties = matchingProperties;
        }
      }

      if (authRequest.isOptional) {
        // if the auth in the request is optional, we consider that its properties are all matching
        maxMatchingProperties = 7; // 111
      }
      _handleAuthErrors(maxMatchingProperties, authRequest);
    }
  }

  function _checkClaimsInRequestMatchWithClaimsInResponse(
    ClaimRequest[] memory claimsInRequest,
    Claim[] memory claimsInResponse
  ) internal pure {
    for (uint256 i = 0; i < claimsInRequest.length; i++) {
      uint8 maxMatchingProperties = 0;
      ClaimRequest memory claimRequest = claimsInRequest[i];
      for (uint256 j = 0; j < claimsInResponse.length; j++) {
        uint8 matchingProperties = 0;
        Claim memory claim = claimsInResponse[j];
        if (claim.claimType == claimRequest.claimType) {
          matchingProperties += 1; // 001
        }
        if (claim.groupId == claimRequest.groupId) {
          matchingProperties += 2; // 010
        }
        if (claim.groupTimestamp == claimRequest.groupTimestamp) {
          matchingProperties += 4; // 100
        }
        if (matchingProperties > maxMatchingProperties) {
          maxMatchingProperties = matchingProperties;
        }
      }
      if (claimRequest.isOptional) {
        maxMatchingProperties = 7; // 111
      }
      _handleClaimErrors(maxMatchingProperties, claimRequest);
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

  function _handleAuthErrors(uint8 maxMatchingProperties, AuthRequest memory auth) internal pure {
    // if the maxMatchingProperties is equal to 7 (111 in bits), it means that the auth in the request matches with one of the auths in the response
    // otherwise, we can look at the binary representation of the maxMatchingProperties to know which properties are not matching and throw an error (the 0 bits represent the properties that are not matching)
    if (maxMatchingProperties == 0) {
      // 000
      // no property of the auth in the request matches with any property of the auths in the response
      revert SismoConnectError.AuthInRequestNotFoundInResponse(
        uint8(auth.authType),
        auth.isAnon,
        auth.userId,
        auth.extraData
      );
    } else if (maxMatchingProperties == 1) {
      // 001
      // only the authType property of the auth in the request matches with one of the auths in the response
      revert SismoConnectError.AuthIsAnonAndUserIdNotFound(auth.isAnon, auth.userId);
    } else if (maxMatchingProperties == 2) {
      // 010
      // only the isAnon property of the auth in the request matches with one of the auths in the response
      revert SismoConnectError.AuthTypeAndUserIdNotFound(uint8(auth.authType), auth.userId);
    } else if (maxMatchingProperties == 3) {
      // 011
      // only the authType and isAnon properties of the auth in the request match with one of the auths in the response
      revert SismoConnectError.AuthUserIdNotFound(auth.userId);
    } else if (maxMatchingProperties == 4) {
      // 100
      // only the userId property of the auth in the request matches with one of the auths in the response
      revert SismoConnectError.AuthTypeAndIsAnonNotFound(uint8(auth.authType), auth.isAnon);
    } else if (maxMatchingProperties == 5) {
      // 101
      // only the authType and userId properties of the auth in the request matches with one of the auths in the response
      revert SismoConnectError.AuthIsAnonNotFound(auth.isAnon);
    } else if (maxMatchingProperties == 6) {
      // 110
      // only the isAnon and userId properties of the auth in the request matches with one of the auths in the response
      revert SismoConnectError.AuthTypeNotFound(uint8(auth.authType));
    }
  }

  function _handleClaimErrors(
    uint8 maxMatchingProperties,
    ClaimRequest memory claim
  ) internal pure {
    // if the maxMatchingProperties is equal to 7 (111 in bits), it means that the claim in the request matches with one of the claims in the response
    // otherwise, we can look at the binary representation of the maxMatchingProperties to know which properties are not matching and throw an error (the 0 bits represent the properties that are not matching)
    if (maxMatchingProperties == 0) {
      // 000
      // no property of the claim in the request matches with any property of the claims in the response
      revert SismoConnectError.ClaimInRequestNotFoundInResponse(
        uint8(claim.claimType),
        claim.groupId,
        claim.groupTimestamp,
        claim.value,
        claim.extraData
      );
    } else if (maxMatchingProperties == 1) {
      // 001
      // only the claimType property of the claim in the request matches with one of the claims in the response
      revert SismoConnectError.ClaimGroupIdAndGroupTimestampNotFound(
        claim.groupId,
        claim.groupTimestamp
      );
    } else if (maxMatchingProperties == 2) {
      // 010
      // only the groupId property of the claim in the request matches with one of the claims in the response
      revert SismoConnectError.ClaimTypeAndGroupTimestampNotFound(
        uint8(claim.claimType),
        claim.groupTimestamp
      );
    } else if (maxMatchingProperties == 3) {
      // 011
      // only the claimType and groupId properties of the claim in the request match with one of the claims in the response
      revert SismoConnectError.ClaimGroupTimestampNotFound(claim.groupTimestamp);
    } else if (maxMatchingProperties == 4) {
      // 100
      // only the groupTimestamp property of the claim in the request matches with one of the claims in the response
      revert SismoConnectError.ClaimTypeAndGroupIdNotFound(uint8(claim.claimType), claim.groupId);
    } else if (maxMatchingProperties == 5) {
      // 101
      // only the claimType and groupTimestamp properties of the claim in the request matches with one of the claims in the response
      revert SismoConnectError.ClaimGroupIdNotFound(claim.groupId);
    } else if (maxMatchingProperties == 6) {
      // 110
      // only the groupId and groupTimestamp properties of the claim in the request matches with one of the claims in the response
      revert SismoConnectError.ClaimTypeNotFound(uint8(claim.claimType));
    }
  }
}
