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
  error AuthInResponseNotFoundInRequest(AuthType responseAuthType, bool responseIsAnon, uint256 responseUserId, bytes responseExtraData);
  error AuthTypeMismatch(AuthType responseAuthType);
  error AuthIsAnonMismatch(bool responseIsAnon);
  error AuthUserIdMismatch(uint256 responseUserId);

  error AuthIsAnonUserIdAndExtraDataMismatch(bool responseIsAnon, uint256 responseUserId, bytes responseExtraData);
  error AuthTypeUserIdAndExtraDataMismatch(AuthType responseAuthType, uint256 responseUserId, bytes responseExtraData);
  error AuthUserIdAndExtraDataMismatch(uint256 responseUserId, bytes responseExtraData);
  error AuthTypeIsAnonAndExtraDataMismatch(AuthType responseAuthType, bool responseIsAnon, bytes responseExtraData);
  error AuthIsAnonAndExtraDataMismatch(bool responseIsAnon, bytes responseExtraData);
  error AuthTypeAndExtraDataMismatch(AuthType responseAuthType, bytes responseExtraData);
  error AuthExtraDataMismatch(bytes responseExtraData);
  error AuthTypeIsAnonAndUserIdMismatch(AuthType responseAuthType, bool responseIsAnon, uint256 responseUserId);
  error AuthIsAnonAndUserIdMismatch(bool responseIsAnon, uint256 responseUserId);
  error AuthTypeAndUserIdMismatch(AuthType responseAuthType, uint256 responseUserId);
  error AuthTypeAndIsAnonMismatch(AuthType responseAuthType, bool responseIsAnon);

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
