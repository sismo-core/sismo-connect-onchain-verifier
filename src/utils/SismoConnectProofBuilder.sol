// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";

library ProofBuilder {
  // default values for SismoConnect Proof
  bytes32 public constant DEFAULT_PROOF_PROVING_SCHEME = bytes32("hydra-s3.1");
  bytes public constant DEFAULT_PROOF_EXTRA_DATA = "";

  function build(
    Auth memory auth,
    bytes memory proofData,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectProof memory) {
    Auth[] memory auths = new Auth[](1);
    auths[0] = auth;
    Claim[] memory claims = new Claim[](0);
    return
      SismoConnectProof({
        auths: auths,
        claims: claims,
        proofData: proofData,
        provingScheme: provingScheme,
        extraData: DEFAULT_PROOF_EXTRA_DATA
      });
  }

  function build(
    Auth memory auth,
    bytes memory proofData
  ) internal pure returns (SismoConnectProof memory) {
    Auth[] memory auths = new Auth[](1);
    auths[0] = auth;
    Claim[] memory claims = new Claim[](0);
    return
      SismoConnectProof({
        auths: auths,
        claims: claims,
        proofData: proofData,
        provingScheme: DEFAULT_PROOF_PROVING_SCHEME,
        extraData: DEFAULT_PROOF_EXTRA_DATA
      });
  }

  function build(
    Claim memory claim,
    bytes memory proofData
  ) internal pure returns (SismoConnectProof memory) {
    Auth[] memory auths = new Auth[](0);
    Claim[] memory claims = new Claim[](1);
    claims[0] = claim;
    return
      SismoConnectProof({
        auths: auths,
        claims: claims,
        proofData: proofData,
        provingScheme: DEFAULT_PROOF_PROVING_SCHEME,
        extraData: DEFAULT_PROOF_EXTRA_DATA
      });
  }

  function build(
    Claim memory claim,
    bytes memory proofData,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectProof memory) {
    Auth[] memory auths = new Auth[](0);
    Claim[] memory claims = new Claim[](1);
    claims[0] = claim;
    return
      SismoConnectProof({
        auths: auths,
        claims: claims,
        proofData: proofData,
        provingScheme: provingScheme,
        extraData: DEFAULT_PROOF_EXTRA_DATA
      });
  }
}
