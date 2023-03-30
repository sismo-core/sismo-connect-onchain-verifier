// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

interface IZkConnectVerifier {
  error InvalidZkConnectVersion(bytes32 receivedVersion, bytes32 expectedVersion);
  error ProofNeedsAuthOrClaim();
  error ProofsAndDataRequestsAreUnequalInLength(uint256 proofsLength, uint256 dataRequestsLength);
  error OnlyOneProofSupportedWithLogicalOperatorOR();
  error ProvingSchemeNotSupported(bytes32 provingScheme);
  error ClaimRequestNotFound(bytes16 groupId, bytes16 groupTimestamp);
  error ClaimTypeMismatch(ClaimType claimType, ClaimType expectedClaimType);
  error ClaimExtraDataMismatch(bytes extraData, bytes expectedExtraData);
  error ClaimProvingSchemeMismatch(bytes32 provingScheme, bytes32 expectedProvingScheme);
  error ClaimValueMismatch(ClaimType claimType, uint256 value, uint256 expectedValue);
  error AuthProofIsEmpty();
  error AuthRequestNotFound(AuthType authType, bool anonMode);
  error AuthUserIdMismatch(uint256 userId, uint256 expectedUserId);

  event VerifierSet(bytes32, address);

  function verify(
    ZkConnectResponse memory zkConnectResponse,
    ZkConnectRequestContent memory zkConnectRequestContent
  ) external returns (ZkConnectVerifiedResult memory);

  function ZK_CONNECT_VERSION() external view returns (bytes32);
}
