// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

interface ISismoConnectVerifier {
  ////Errors: Request/Response mismatch errors
  error VersionMismatch(bytes32 requestVersion, bytes32 responseVersion);
  error NamespaceMismatch(bytes16 requestNamespace, bytes16 responseNamespace);
  error AppIdMismatch(bytes16 requestAppId, bytes16 responseAppId);
  error SignatureMessageMismatch(bytes requestMessageSignature, bytes responseMessageSignature);
  // Auth mismatch errors
  error AuthInRequestNotFoundInResponse(uint8 requestAuthType, bool requestIsAnon, uint256 requestUserId, bytes requestExtraData);
  error AuthIsAnonAndUserIdNotFound(bool requestIsAnon, uint256 requestUserId);
  error AuthTypeAndUserIdNotFound(uint8 requestAuthType, uint256 requestUserId);
  error AuthUserIdNotFound(uint256 requestUserId);
  error AuthTypeAndIsAnonNotFound(uint8 requestAuthType, bool requestIsAnon);
  error AuthIsAnonNotFound(bool requestIsAnon);
  error AuthTypeNotFound(uint8 requestAuthType);

  // Claim mismatch errors
  error ClaimInRequestNotFoundInResponse(uint8 responseClaimType, bytes16 responseClaimGroupId, bytes16 responseClaimGroupTimestamp, uint256 responseClaimValue, bytes responseExtraData);
  error ClaimGroupIdAndGroupTimestampNotFound(bytes16 requestClaimGroupId, bytes16 requestClaimGroupTimestamp);
  error ClaimTypeAndGroupTimestampNotFound(uint8 requestClaimType, bytes16 requestClaimGroupTimestamp);
  error ClaimGroupTimestampNotFound(bytes16 requestClaimGroupTimestamp);
  error ClaimTypeAndGroupIdNotFound(uint8 requestClaimType, bytes16 requestClaimGroupId);
  error ClaimGroupIdNotFound(bytes16 requestClaimGroupId);
  error ClaimTypeNotFound(uint8 requestClaimType);

  event VerifierSet(bytes32, address);

  function verify(
    SismoConnectResponse memory response,
    SismoConnectRequest memory request
  ) external returns (SismoConnectVerifiedResult memory);

  function SISMO_CONNECT_VERSION() external view returns (bytes32);
}
