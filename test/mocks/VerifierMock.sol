// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IBaseVerifier} from "src/interfaces/IBaseVerifier.sol";
import {Auth, ClaimType, AuthType, Claim, SismoConnectProof, VerifiedAuth, VerifiedClaim} from "src/utils/Structs.sol";

contract VerifierMock is IBaseVerifier {
  bytes32 public immutable VERSION = "mock-scheme";

  function verify(
    bytes16,
    bytes16,
    bool,
    bytes memory,
    SismoConnectProof memory sismoConnectProof
  ) external pure override returns (VerifiedAuth memory, VerifiedClaim memory) {
    // Verify Claim, Auth and SignedMessage validity by checking corresponding
    // snarkProof public input
    VerifiedAuth memory verifiedAuth;
    VerifiedClaim memory verifiedClaim;
    if (sismoConnectProof.auths.length == 1) {
      // Get the Auth from the sismoConnectProof
      // We only support one Auth in the hydra-s3 proving scheme
      Auth memory auth = sismoConnectProof.auths[0];
      verifiedAuth = VerifiedAuth({
        authType: auth.authType,
        isAnon: auth.isAnon,
        userId: auth.userId,
        extraData: auth.extraData,
        proofData: hex""
      });
    }
    if (sismoConnectProof.claims.length == 1) {
      // Get the Claim from the sismoConnectProof
      // We only support one Claim in the hydra-s3 proving scheme
      Claim memory claim = sismoConnectProof.claims[0];
      verifiedClaim = VerifiedClaim({
        claimType: claim.claimType,
        groupId: claim.groupId,
        groupTimestamp: claim.groupTimestamp,
        value: claim.value,
        extraData: claim.extraData,
        proofId: 0x0,
        proofData: hex""
      });
    }

    return (verifiedAuth, verifiedClaim);
  }
}
