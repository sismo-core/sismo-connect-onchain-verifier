// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";

library ClaimMatchingLib {
  error ClaimInRequestNotFoundInResponse(
    uint8 responseClaimType,
    bytes16 responseClaimGroupId,
    bytes16 responseClaimGroupTimestamp,
    uint256 responseClaimValue,
    bytes responseExtraData
  );
  error ClaimGroupIdAndGroupTimestampNotFound(
    bytes16 requestClaimGroupId,
    bytes16 requestClaimGroupTimestamp
  );
  error ClaimTypeAndGroupTimestampNotFound(
    uint8 requestClaimType,
    bytes16 requestClaimGroupTimestamp
  );
  error ClaimGroupTimestampNotFound(bytes16 requestClaimGroupTimestamp);
  error ClaimTypeAndGroupIdNotFound(uint8 requestClaimType, bytes16 requestClaimGroupId);
  error ClaimGroupIdNotFound(bytes16 requestClaimGroupId);
  error ClaimTypeNotFound(uint8 requestClaimType);

  // Check if the AuthRequest is fulfilled by the Auth in the response
  // and return the level of matching between the AuthRequest and the Auth in the response
  function _matchLevel(
    Claim memory claim,
    ClaimRequest memory claimRequest
  ) internal pure returns (uint8) {
    uint8 matchingPropertiesLevel = 0;

    if (claim.claimType == claimRequest.claimType) {
      matchingPropertiesLevel += 1; // 001
    }
    if (claim.groupId == claimRequest.groupId) {
      matchingPropertiesLevel += 2; // 010
    }
    if (claim.groupTimestamp == claimRequest.groupTimestamp) {
      matchingPropertiesLevel += 4; // 100
    }

    return matchingPropertiesLevel;
  }

  function handleClaimErrors(uint8 maxMatchingProperties, ClaimRequest memory claim) public pure {
    // if the maxMatchingProperties is equal to 7 (111 in bits), it means that the claim in the request matches with one of the claims in the response
    // otherwise, we can look at the binary representation of the maxMatchingProperties to know which properties are not matching and throw an error (the 0 bits represent the properties that are not matching)
    if (maxMatchingProperties == 0) {
      // 000
      // no property of the claim in the request matches with any property of the claims in the response
      revert ClaimInRequestNotFoundInResponse(
        uint8(claim.claimType),
        claim.groupId,
        claim.groupTimestamp,
        claim.value,
        claim.extraData
      );
    } else if (maxMatchingProperties == 1) {
      // 001
      // only the claimType property of the claim in the request matches with one of the claims in the response
      revert ClaimGroupIdAndGroupTimestampNotFound(claim.groupId, claim.groupTimestamp);
    } else if (maxMatchingProperties == 2) {
      // 010
      // only the groupId property of the claim in the request matches with one of the claims in the response
      revert ClaimTypeAndGroupTimestampNotFound(uint8(claim.claimType), claim.groupTimestamp);
    } else if (maxMatchingProperties == 3) {
      // 011
      // only the claimType and groupId properties of the claim in the request match with one of the claims in the response
      revert ClaimGroupTimestampNotFound(claim.groupTimestamp);
    } else if (maxMatchingProperties == 4) {
      // 100
      // only the groupTimestamp property of the claim in the request matches with one of the claims in the response
      revert ClaimTypeAndGroupIdNotFound(uint8(claim.claimType), claim.groupId);
    } else if (maxMatchingProperties == 5) {
      // 101
      // only the claimType and groupTimestamp properties of the claim in the request matches with one of the claims in the response
      revert ClaimGroupIdNotFound(claim.groupId);
    } else if (maxMatchingProperties == 6) {
      // 110
      // only the groupId and groupTimestamp properties of the claim in the request matches with one of the claims in the response
      revert ClaimTypeNotFound(uint8(claim.claimType));
    }
  }
}
