// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "src/libs/utils/Structs.sol";

library SismoConnectError {
  error SismoConnectResponseIsEmpty();
  error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
  error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);

  ///////////////////////////////////////
  // ZkConnectVerifier Errors
  ///////////////////////////////////////

  ////Errors: Request/Response mismatch errors
  error VersionMismatch(bytes32 requestVersion, bytes32 responseVersion);
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

  ///////////////////////////////////////
  // HydraS2Verifier Errors
  ///////////////////////////////////////
  error InvalidProof();
  error AnonModeIsNotYetSupported();
  error OnlyOneAuthAndOneClaimIsSupported();

  error InvalidVersion(bytes32 version);
  error RegistryRootNotAvailable(uint256 inputRoot);
  error DestinationMismatch(address destinationFromProof, address expectedDestination);
  error CommitmentMapperPubKeyMismatch(
    bytes32 expectedX,
    bytes32 expectedY,
    bytes32 inputX,
    bytes32 inputY
  );

  error ClaimTypeMismatch(uint256 claimTypeFromProof, uint256 expectedClaimType);
  error RequestIdentifierMismatch(
    uint256 requestIdentifierFromProof,
    uint256 expectedRequestIdentifier
  );
  error InvalidExtraData(uint256 extraDataFromProof, uint256 expectedExtraData);
  error ClaimValueMismatch();
  error DestinationVerificationNotEnabled();
  error SourceVerificationNotEnabled();
  error AccountsTreeValueMismatch(
    uint256 accountsTreeValueFromProof,
    uint256 expectedAccountsTreeValue
  );
  error VaultNamespaceMismatch(uint256 vaultNamespaceFromProof, uint256 expectedVaultNamespace);
  error UserIdMismatch(uint256 userIdFromProof, uint256 expectedUserId);
}