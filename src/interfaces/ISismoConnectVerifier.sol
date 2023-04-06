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
  error AuthInRequestNotFoundInResponse(AuthType requestAuthType, bool requestIsAnon, uint256 requestUserId, bytes requestExtraData);
  error AuthTypeMismatch(AuthType requestAuthType);
  error AuthIsAnonMismatch(bool requestIsAnon);
  error AuthUserIdMismatch(uint256 requestUserId);

  error AuthIsAnonUserIdAndExtraDataMismatch(bool requestIsAnon, uint256 requestUserId, bytes requestExtraData);
  error AuthTypeUserIdAndExtraDataMismatch(AuthType requestAuthType, uint256 requestUserId, bytes requestExtraData);
  error AuthUserIdAndExtraDataMismatch(uint256 requestUserId, bytes requestExtraData);
  error AuthTypeIsAnonAndExtraDataMismatch(AuthType requestAuthType, bool requestIsAnon, bytes requestExtraData);
  error AuthIsAnonAndExtraDataMismatch(bool requestIsAnon, bytes requestExtraData);
  error AuthTypeAndExtraDataMismatch(AuthType requestAuthType, bytes requestExtraData);
  error AuthExtraDataMismatch(bytes requestExtraData);
  error AuthTypeIsAnonAndUserIdMismatch(AuthType requestAuthType, bool requestIsAnon, uint256 requestUserId);
  error AuthIsAnonAndUserIdMismatch(bool requestIsAnon, uint256 requestUserId);
  error AuthTypeAndUserIdMismatch(AuthType requestAuthType, uint256 requestUserId);
  error AuthTypeAndIsAnonMismatch(AuthType requestAuthType, bool requestIsAnon);

  // Claim mismatch errors
  error ClaimInResponseNotFoundInRequest(ClaimType responseClaimType, bytes16 responseClaimGroupId, bytes16 responseClaimGroupTimestamp, uint256 responseClaimValue, bytes responseExtraData);
  error ClaimTypeMismatch(ClaimType requestClaimType, ClaimType responseClaimType);
  error ClaimValueMismatch(uint256 requestClaimValue, uint256 responseClaimValue);
  error ClaimExtraDataMismatch(bytes requestExtraData, bytes responseExtraData);
  error ClaimGroupIdMismatch(bytes16 requestGroupId, bytes16 responseGroupId);
  error ClaimGroupTimestampMismatch(bytes16 requestGroupTimestamp, bytes16 responseGroupTimestamp);

  event VerifierSet(bytes32, address);

  function verify(
    SismoConnectResponse memory response,
    SismoConnectRequest memory request
  ) external returns (SismoConnectVerifiedResult memory);

  function SISMO_CONNECT_VERSION() external view returns (bytes32);
}
