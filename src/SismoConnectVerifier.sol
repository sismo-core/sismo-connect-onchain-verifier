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

    uint256 responseProofsArrayLength = response.proofs.length;
    uint256 authsInResponseLength = 0;
    uint256 claimsInResponseLength = 0;
    // Count the number of auths and claims in the response
    for (uint256 i = 0; i < responseProofsArrayLength; i++) {
      authsInResponseLength += response.proofs[i].auths.length;
      claimsInResponseLength += response.proofs[i].claims.length;
    }

    VerifiedAuth[] memory verifiedAuths = new VerifiedAuth[](authsInResponseLength);
    VerifiedClaim[] memory verifiedClaims = new VerifiedClaim[](claimsInResponseLength);

    for (uint256 i = 0; i < responseProofsArrayLength; i++) {
      (
        VerifiedAuth memory verifiedAuth,
        VerifiedClaim memory verifiedClaim
      ) = _verifiers[response.proofs[i].provingScheme].verify({
          appId: response.appId,
          namespace: response.namespace,
          signedMessage: response.signedMessage,
          sismoConnectProof: response.proofs[i]
        });

      verifiedAuths[i] = verifiedAuth;
      verifiedClaims[i] = verifiedClaim;
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

    for (uint256 i = 0; i < response.proofs.length; i++) {
      SismoConnectProof memory proof = response.proofs[i];
      // Check if the auths and claims in the response match the auths and claims int the request
      _checkAuthsInResponseMatchWithAuthsInRequest({auths: proof.auths, authRequests: request.auths});
      _checkClaimsInResponseMatchWithClaimsInRequest({claims: proof.claims, claimRequests: request.claims});
    }
  }

  function _checkAuthsInResponseMatchWithAuthsInRequest(
    Auth[] memory auths,
    AuthRequest[] memory authRequests
  ) internal pure {
    // for each auth in the request, we check if it matches with one of the auths in the response
    for (uint256 i = 0; i < authRequests.length; i++) {
      // we store the information about the maximum matching properties in a uint8 
      // if the auth in the request matches with an auth in the response, the matchingProperties will be equal to 15 (1111)
      // otherwise, we can look at the binary representation of the matchingProperties to know which properties are not matching and throw an error
      uint8 maxMatchingProperties = 0;
      AuthRequest memory authRequest = authRequests[i];
      for (uint256 j = 0; j < auths.length; j++) {
        // we store the matching properties for the current auth in the response in a uint8
        // we will store it in the maxMatchingProperties variable if it is greater than the current value of maxMatchingProperties
        uint8 matchingProperties = 0;
        Auth memory auth = auths[j];
        if (auth.authType == authRequest.authType) {
          matchingProperties += 1; // 0001
        }
        if (auth.isAnon == authRequest.isAnon) {
          matchingProperties += 2; // 0010
        }
        if (auth.userId != authRequest.userId) {
          matchingProperties += 4; // 0100
        }
        if (keccak256(auth.extraData) != keccak256(authRequest.extraData)) {
          matchingProperties += 8; // 1000
        }
        // if the matchingProperties are greater than the current value of maxMatchingProperties, we update the value of maxMatchingProperties
        // by doing so we will be able to know how close the auth in the request is to the auth in the response
        if (matchingProperties > maxMatchingProperties) {
          maxMatchingProperties = matchingProperties;
        }
      }
      _handleAuthErrors(maxMatchingProperties, authRequest);
    }
  }

  function _checkClaimsInResponseMatchWithClaimsInRequest(
    Claim[] memory claims,
    ClaimRequest[] memory claimRequests
  ) internal pure {
    for (uint256 i=0; i < claimRequests.length; i++) {
      uint8 maxMatchingProperties = 0;
      ClaimRequest memory claimRequest = claimRequests[i];
      for (uint256 j=0; j < claims.length; j++) {
        uint8 matchingProperties = 0;
        Claim memory claim = claims[j];
        if (claim.claimType == claimRequest.claimType) {
          matchingProperties += 1; // 0001
        }
        if (claim.groupId == claimRequest.groupId) {
          matchingProperties += 2; // 0010
        }
        if (claim.groupTimestamp == claimRequest.groupTimestamp) {
          matchingProperties += 4; // 0100
        }
        if (claim.value == claimRequest.value) {
          matchingProperties += 8; // 1000
        }
        if (keccak256(claim.extraData) == keccak256(claimRequest.extraData)) {
          matchingProperties += 16; // 10000
        }
        if (matchingProperties > maxMatchingProperties) {
          maxMatchingProperties = matchingProperties;
        }
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
      // if the maxMatchingProperties is equal to 15 (1111), it means that the auth in the request matches with one of the auths in the response
      // otherwise, we can look at the binary representation of the maxMatchingProperties to know which properties are not matching and throw an error
      if (maxMatchingProperties == 0) { // 0000
      // if maxMatchingProperties == 0000, it means that no property of the auth in the request matches with any property of the auths in the response
      revert AuthInRequestNotFoundInResponse(auth.authType, auth.isAnon, auth.userId, auth.extraData);
      } else if (maxMatchingProperties == 1) {
      // if maxMatchingProperties == 0001, it means that only the authType property of the auth in the request matches with one of the auths in the response
      revert AuthIsAnonUserIdAndExtraDataMismatch(auth.isAnon, auth.userId, auth.extraData);
      } else if (maxMatchingProperties == 2) {
      // if maxMatchingProperties == 0010, it means that only the isAnon property of the auth in the request matches with one of the auths in the response
      revert AuthTypeUserIdAndExtraDataMismatch(auth.authType, auth.userId, auth.extraData);
      } else if (maxMatchingProperties == 3) {
      // if maxMatchingProperties == 0011, it means that only the authType and isAnon properties of the auth in the request matches with one of the auths in the response
      revert AuthUserIdAndExtraDataMismatch(auth.userId, auth.extraData);
      } else if (maxMatchingProperties == 4) {
      // if maxMatchingProperties == 0100, it means that only the userId property of the auth in the request matches with one of the auths in the response
      revert AuthTypeIsAnonAndExtraDataMismatch(auth.authType, auth.isAnon, auth.extraData);
      } else if (maxMatchingProperties == 5) {
      // if maxMatchingProperties == 0101, it means that only the authType and userId properties of the auth in the request matches with one of the auths in the response
      revert AuthIsAnonAndExtraDataMismatch(auth.isAnon, auth.extraData);
      } else if (maxMatchingProperties == 6) {
      // if maxMatchingProperties == 0110, it means that only the isAnon and userId properties of the auth in the request matches with one of the auths in the response
      revert AuthTypeAndExtraDataMismatch(auth.authType, auth.extraData);
      } else if (maxMatchingProperties == 7) {
      // if maxMatchingProperties == 0111, it means that only the authType, isAnon and userId properties of the auth in the request matches with one of the auths in the response
      revert AuthExtraDataMismatch(auth.extraData);
      } else if (maxMatchingProperties == 8) {
      // if maxMatchingProperties == 1000, it means that only the extraData property of the auth in the request matches with one of the auths in the response
      revert AuthTypeIsAnonAndUserIdMismatch(auth.authType, auth.isAnon, auth.userId);
      } else if (maxMatchingProperties == 9) {
      // if maxMatchingProperties == 1001, it means that only the authType and extraData properties of the auth in the request matches with one of the auths in the response
      revert AuthIsAnonAndUserIdMismatch(auth.isAnon, auth.userId);
      } else if (maxMatchingProperties == 10) {
      // if maxMatchingProperties == 1010, it means that only the isAnon and extraData properties of the auth in the request matches with one of the auths in the response
      revert AuthTypeAndUserIdMismatch(auth.authType, auth.userId);
      } else if (maxMatchingProperties == 11) {
      // if maxMatchingProperties == 1011, it means that only the authType, isAnon and extraData properties of the auth in the request matches with one of the auths in the response
      revert AuthUserIdMismatch(auth.userId);
      } else if (maxMatchingProperties == 12) {
      // if maxMatchingProperties == 1100, it means that only the userId and extraData properties of the auth in the request matches with one of the auths in the response
      revert AuthTypeAndIsAnonMismatch(auth.authType, auth.isAnon);
      } else if (maxMatchingProperties == 13) {
      // if maxMatchingProperties == 1101, it means that only the authType, userId and extraData properties of the auth in the request matches with one of the auths in the response
      revert AuthIsAnonMismatch(auth.isAnon);
      } else if (maxMatchingProperties == 14) {
      // if maxMatchingProperties == 1110, it means that only the isAnon, userId and extraData properties of the auth in the request matches with one of the auths in the response
      revert AuthTypeMismatch(auth.authType);
      }
  } 

  function _handleClaimErrors(uint8 maxMatchingProperties, ClaimRequest memory claim) internal pure {
      //TODO: implement
      if (maxMatchingProperties != 31) { // 11111
        revert ClaimInResponseNotFoundInRequest(claim.claimType, claim.groupId, claim.groupTimestamp, claim.value, claim.extraData);
      }
  }
}
