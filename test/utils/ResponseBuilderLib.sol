// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/utils/Structs.sol";
import {ProofBuilder} from "src/utils/SismoConnectProofBuilder.sol";

// We introduce an intermediate struct that will not store the proofs
// This is useful to be able to store this struct in the a contract storage
// We will then use different function to add the proofs and build the SismoConnectResponse struct
struct ResponseWithoutProofs {
  bytes16 appId;
  bytes16 namespace;
  bytes32 version;
  bytes signedMessage;
}

// This library aims at building SismoConnectResponse structs with less overhead
// than using the SismoConnectResponse struct directly
// It also allows to build the SismoConnectResponse struct in multiple steps
// by adding the proofs later, ensuring modularity and flexibility in the code
library ResponseBuilder {
  //////////////////////////////////
  // Simple Field Initialization //
  ////////////////////////////////

  function withAppId(
    SismoConnectResponse memory response,
    bytes16 appId
  ) internal pure returns (SismoConnectResponse memory) {
    response.appId = appId;
    return response;
  }

  function withAppId(
    ResponseWithoutProofs memory response,
    bytes16 appId
  ) internal pure returns (ResponseWithoutProofs memory) {
    response.appId = appId;
    return response;
  }

  function withVersion(
    SismoConnectResponse memory response,
    bytes32 version
  ) internal pure returns (SismoConnectResponse memory) {
    response.version = version;
    return response;
  }

  function withVersion(
    ResponseWithoutProofs memory response,
    bytes32 version
  ) internal pure returns (ResponseWithoutProofs memory) {
    response.version = version;
    return response;
  }

  function withNamespace(
    SismoConnectResponse memory response,
    bytes16 namespace
  ) internal pure returns (SismoConnectResponse memory) {
    response.namespace = namespace;
    return response;
  }

  function withNamespace(
    ResponseWithoutProofs memory response,
    bytes16 namespace
  ) internal pure returns (ResponseWithoutProofs memory) {
    response.namespace = namespace;
    return response;
  }

  function withSignedMessage(
    SismoConnectResponse memory response,
    bytes memory signedMessage
  ) internal pure returns (SismoConnectResponse memory) {
    response.signedMessage = signedMessage;
    return response;
  }

  function withSignedMessage(
    ResponseWithoutProofs memory response,
    bytes memory signedMessage
  ) internal pure returns (ResponseWithoutProofs memory) {
    response.signedMessage = signedMessage;
    return response;
  }

  //////////////////////////////////
  //      Proof Initialization   //
  ////////////////////////////////

  // the `build` function is used to build a valid Sismo Connect response from a ResponseWithoutProofs struct
  // it just adds an empty array of proofs to the ResponseWithoutProofs struct
  // it has a internal visibility because it is used inside this library to transform a ResponseWithoutProofs struct into a SismoConnectResponse struct
  // but it can also be used outside this library to build a SismoConnectResponse struct from a ResponseWithoutProofs struct
  function build(
    ResponseWithoutProofs memory response
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory proofs = new SismoConnectProof[](0);
    return
      SismoConnectResponse({
        appId: response.appId,
        namespace: response.namespace,
        version: response.version,
        signedMessage: response.signedMessage,
        proofs: proofs
      });
  }

  function withAuth(
    SismoConnectResponse memory response,
    Auth memory auth,
    bytes memory proofData,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory newProofs = new SismoConnectProof[](1);
    newProofs[0] = ProofBuilder.build({
      auth: auth,
      proofData: proofData,
      provingScheme: provingScheme
    });
    SismoConnectProof[] memory allProofs = getAllProofs(response, newProofs);
    response.proofs = allProofs;
    return response;
  }

  function withAuth(
    SismoConnectResponse memory response,
    Auth memory auth,
    bytes memory proofData
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory newProofs = new SismoConnectProof[](1);
    newProofs[0] = ProofBuilder.build({auth: auth, proofData: proofData, provingScheme: ""});
    SismoConnectProof[] memory allProofs = getAllProofs(response, newProofs);
    response.proofs = allProofs;
    return response;
  }

  function withAuth(
    SismoConnectResponse memory response,
    Auth memory auth
  ) internal pure returns (SismoConnectResponse memory) {
    return withAuth(response, auth, "");
  }

  function withAuth(
    ResponseWithoutProofs memory response,
    Auth memory auth,
    bytes memory proofData,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = ProofBuilder.build({
      auth: auth,
      proofData: proofData,
      provingScheme: provingScheme
    });
    SismoConnectResponse memory responseWithProofs = build(response);
    responseWithProofs.proofs = proofs;
    return responseWithProofs;
  }

  function withAuth(
    ResponseWithoutProofs memory response,
    Auth memory auth,
    bytes memory proofData
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = ProofBuilder.build({auth: auth, proofData: proofData, provingScheme: ""});
    SismoConnectResponse memory responseWithProofs = build(response);
    responseWithProofs.proofs = proofs;
    return responseWithProofs;
  }

  function withAuth(
    ResponseWithoutProofs memory response,
    Auth memory auth,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = ProofBuilder.build({auth: auth, proofData: "", provingScheme: provingScheme});
    SismoConnectResponse memory responseWithProofs = build(response);
    responseWithProofs.proofs = proofs;
    return responseWithProofs;
  }

  function withAuth(
    ResponseWithoutProofs memory response,
    Auth memory auth
  ) internal pure returns (SismoConnectResponse memory) {
    return withAuth({response: response, auth: auth, proofData: ""});
  }

  function withClaim(
    SismoConnectResponse memory response,
    Claim memory claim,
    bytes memory proofData,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory newProofs = new SismoConnectProof[](1);
    newProofs[0] = ProofBuilder.build({
      claim: claim,
      proofData: proofData,
      provingScheme: provingScheme
    });
    SismoConnectProof[] memory allProofs = getAllProofs(response, newProofs);
    response.proofs = allProofs;
    return response;
  }

  function withClaim(
    SismoConnectResponse memory response,
    Claim memory claim,
    bytes memory proofData
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory newProofs = new SismoConnectProof[](1);
    newProofs[0] = ProofBuilder.build({claim: claim, proofData: proofData, provingScheme: ""});
    SismoConnectProof[] memory allProofs = getAllProofs(response, newProofs);
    response.proofs = allProofs;
    return response;
  }

  function withClaim(
    SismoConnectResponse memory response,
    Claim memory claim,
    bytes32 provingScheme
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory newProofs = new SismoConnectProof[](1);
    newProofs[0] = ProofBuilder.build({claim: claim, proofData: "", provingScheme: provingScheme});
    SismoConnectProof[] memory allProofs = getAllProofs(response, newProofs);
    response.proofs = allProofs;
    return response;
  }

  function withClaim(
    SismoConnectResponse memory response,
    Claim memory claim
  ) internal pure returns (SismoConnectResponse memory) {
    return withClaim({response: response, claim: claim, proofData: ""});
  }

  function withClaim(
    ResponseWithoutProofs memory response,
    Claim memory claim,
    bytes memory proofData
  ) internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = ProofBuilder.build({claim: claim, proofData: proofData});
    SismoConnectResponse memory responseWithProofs = build(response);
    responseWithProofs.proofs = proofs;
    return responseWithProofs;
  }

  function withClaim(
    ResponseWithoutProofs memory response,
    Claim memory claim
  ) internal pure returns (SismoConnectResponse memory) {
    return withClaim(response, claim, "");
  }

  ////////////////////////////////
  //  Multiple Proof Addition  //
  //////////////////////////////

  function getAllProofs(
    SismoConnectResponse memory response,
    SismoConnectProof[] memory newProofs
  ) private pure returns (SismoConnectProof[] memory) {
    uint32 proofsLength = uint32(response.proofs.length);
    uint32 newProofsLength = uint32(newProofs.length);
    SismoConnectProof[] memory allProofs = new SismoConnectProof[](proofsLength + newProofsLength);
    for (uint32 i = 0; i < proofsLength; i++) {
      allProofs[i] = response.proofs[i];
    }
    for (uint32 i = 0; i < newProofsLength; i++) {
      allProofs[proofsLength + i] = newProofs[i];
    }
    return allProofs;
  }

  ////////////////////////////////
  //       Empty structs       //
  //////////////////////////////

  function emptyResponseWithoutProofs() internal pure returns (ResponseWithoutProofs memory) {
    return
      ResponseWithoutProofs({
        appId: bytes16(0),
        namespace: bytes16(0),
        version: bytes32(0),
        signedMessage: ""
      });
  }

  function empty() internal pure returns (SismoConnectResponse memory) {
    SismoConnectProof[] memory proofs = new SismoConnectProof[](0);
    return
      SismoConnectResponse({
        appId: bytes16(0),
        namespace: bytes16(0),
        version: bytes32(0),
        signedMessage: "",
        proofs: proofs
      });
  }
}
