// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IBaseVerifier} from "src/interfaces/IBaseVerifier.sol";
import {Auth, ClaimType, AuthType, Claim, SismoConnectProof, VerifiedAuth, VerifiedClaim} from "src/libs/utils/Structs.sol";

contract ProvingSchemeVerifierMock is IBaseVerifier {
  function verify(
    bytes16 appId,
    bytes16 namespace,
    bytes memory signedMessage,
    SismoConnectProof memory sismoConnectProof
  ) external view override returns (VerifiedAuth memory, VerifiedClaim memory) {
    // Verify Claim, Auth and SignedMessage validity by checking corresponding
    // snarkProof public input
    VerifiedAuth memory verifiedAuth;
    VerifiedClaim memory verifiedClaim;
    if (sismoConnectProof.auths.length == 1) {
      // Get the Auth from the sismoConnectProof
      // We only support one Auth in the hydra-s2 proving scheme
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
      // We only support one Claim in the hydra-s2 proving scheme
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
