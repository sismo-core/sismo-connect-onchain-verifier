// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import {SismoConnectHarness} from "test/harness/SismoConnectHarness.sol";
import "src/libs/sismo-connect/SismoConnectLib.sol";
import {HydraS2ProofData, HydraS2Lib, HydraS2ProofInput} from "src/verifiers/HydraS2Lib.sol";

contract HydraS2VerifierTest is HydraS2BaseTest {
  using HydraS2Lib for HydraS2ProofData;

  SismoConnectHarness sismoConnect;
  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;
  bytes16 constant appId = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 constant groupId = 0xe9ed316946d3d98dfcd829a53ec9822e;
  ClaimRequest claimRequest;
  AuthRequest authRequest;
  SignatureRequest signature;

  HydraS2ProofData snarkProof;

  function setUp() public virtual override {
    super.setUp();
    sismoConnect = new SismoConnectHarness(appId);
    claimRequest = sismoConnect.exposed_buildClaim({groupId: groupId});
    authRequest = sismoConnect.exposed_buildAuth({authType: AuthType.VAULT});
    signature = sismoConnect.exposed_buildSignature({message: abi.encode(user)});
  }

  function test_RevertWith_InvalidVersionOfProvingScheme() public {
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    invalidResponse.proofs[0].provingScheme = bytes32("fake-proving-scheme");
    // register the fake proving scheme to the HydraS2Verifier address i the SismoConnectVerifier contract
    // if the proving scheme is not registered, it will revert without an error since the SismoConnectVerifier will not be able to find the verifier when routing
    vm.prank(owner);
    sismoConnectVerifier.registerVerifier(
      bytes32("fake-proving-scheme"),
      address(hydraS2Verifier)
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "InvalidVersion(bytes32)",
        bytes32("fake-proving-scheme")
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_VaultNamespaceMismatch(uint256 invalidVaultNamespace) public {
    // we force the invalidVaultNamespace to be different from the correct one
    // while being a valid uint128
    vm.assume(invalidVaultNamespace < 2**128 -1);
    vm.assume(invalidVaultNamespace != uint256(keccak256(abi.encodePacked(appId, bytes16(0)))) % HydraS2Lib.SNARK_FIELD);
    (SismoConnectResponse memory invalidResponse, )  = hydraS2Proofs.getResponseWithOnlyOneAuthAndMessage(commitmentMapperRegistry);
    // we change the vaultNamespace to be equal to a random one instead of the coorect appId
    // vaultNamespace is at index 11 is in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 11, invalidVaultNamespace);
    vm.expectRevert(
      abi.encodeWithSignature(
        "VaultNamespaceMismatch(uint256,uint256)",
        snarkProof._getVaultNamespace(),
        uint256(keccak256(abi.encodePacked(appId, bytes16(0)))) % HydraS2Lib.SNARK_FIELD
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), auth: authRequest, signature: signature});
  }

  function test_RevertWith_DestinationVerificationNotEnabled() public {
    (SismoConnectResponse memory invalidResponse, )  = hydraS2Proofs.getResponseWithOnlyOneAuthAndMessage(commitmentMapperRegistry);
    // we change the authType to be equal to GITHUB instead of ANON
    invalidResponse.proofs[0].auths[0] = Auth({authType: AuthType.GITHUB, isAnon: false, isSelectableByUser: true, userId: 0, extraData: ""});

    // we change the authType to be equal to GITHUB instead of ANON, so it is the same as in the response and we can test the revert of the destinationVerificationEnabled
    AuthRequest memory githubAuthRequest = sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB});

    // this should revert because the destinationVerificationEnabled is false and the AuthType is different from ANON
    vm.expectRevert(abi.encodeWithSignature("DestinationVerificationNotEnabled()"));
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), auth: githubAuthRequest, signature: signature});
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyXMismatchWithAuth(uint256 incorrectCommitmentMapperPubKeyX) public {
    // we assume that the incorrectCommitmentMapperPubKeyX is different from the correct commitmentMapperPubKeyX when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyX != hydraS2Proofs.getEdDSAPubKeyDevBeta()[0]);
    (SismoConnectResponse memory invalidResponse, )  = hydraS2Proofs.getResponseWithOnlyOneAuthAndMessage(commitmentMapperRegistry);
    // we change the authType to be equal to GITHUB instead of ANON to be able to check the commitmentMapperRegistry public key
    invalidResponse.proofs[0].auths[0] = Auth({authType: AuthType.GITHUB, isAnon: false, isSelectableByUser: true, userId: 0, extraData: ""});
    // we change the commitmentMapperPubKeyX to be equal to a random uint256 instead of the correct commitmentMapperPubKeyX
    // commitmentMapperPubKeyX is at index 2 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 2, incorrectCommitmentMapperPubKeyX); 
    // we change the destinationVerificationEnabled to be equal to true instead of false
    // with an AuthType different from ANON, the destinationVerificationEnabled should be true
    // destinationVerificationEnabled at index 13 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 13, uint256(1)); // true

    // we change the authType to be equal to GITHUB instead of ANON, so it is the same as in the response and we can test the revert of the destinationVerificationEnabled
    AuthRequest memory githubAuthRequest = sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB});
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), auth: githubAuthRequest, signature: signature});
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyYMismatchWithAuth(uint256 incorrectCommitmentMapperPubKeyY) public {
    // we assume that the incorrectCommitmentMapperPubKeyY is different from the correct commitmentMapperPubKeyY when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyY != hydraS2Proofs.getEdDSAPubKeyDevBeta()[1]);
    (SismoConnectResponse memory invalidResponse, )  = hydraS2Proofs.getResponseWithOnlyOneAuthAndMessage(commitmentMapperRegistry);
    // we change the authType to be equal to GITHUB instead of ANON to be able to check the commitmentMapperRegistry public key
    invalidResponse.proofs[0].auths[0] = Auth({authType: AuthType.GITHUB, isAnon: false, isSelectableByUser: true, userId: 0, extraData: ""});
    // we change the commitmentMapperPubKeyY to be equal to a random uint256 instead of the correct commitmentMapperPubKeyY
    // commitmentMapperPubKeyY is at index 3 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 3, incorrectCommitmentMapperPubKeyY); 
    // we change the destinationVerificationEnabled to be equal to true instead of false
    // with an AuthType different from ANON, the destinationVerificationEnabled should be true
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 13, uint256(1)); // destinationVerificationEnabled at index 13 is equal to true

    // we change the authType to be equal to GITHUB instead of ANON, so it is the same as in the response and we can test the revert of the destinationVerificationEnabled
    AuthRequest memory githubAuthRequest = sismoConnect.exposed_buildAuth({authType: AuthType.GITHUB});
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), auth: githubAuthRequest, signature: signature});
  }

  function testFuzz_RevertWith_ClaimValueMismatch(uint256 invalidClaimValue) public {
    // we force that the invalidClaimValue is different from the correct claimValue when fuzzing
    vm.assume(invalidClaimValue != 1);
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    // claimValue is at index 7 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 7, invalidClaimValue);
    vm.expectRevert(abi.encodeWithSignature("ClaimValueMismatch()"));
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_RequestIdentifierMismatch(uint256 incorrectRequestIdentifier) public {
    uint256 correctRequestIdentifier = _encodeRequestIdentifier(groupId, bytes16("latest"), appId, bytes16(keccak256("main")));
    // we force that the incorrectRequestIdentifier is different from the correct requestIdentifier when fuzzing
    vm.assume(incorrectRequestIdentifier != _encodeRequestIdentifier(groupId, bytes16("latest"), appId, bytes16(keccak256("main"))));
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    // requestIdentifier is at index 5 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 5, incorrectRequestIdentifier); 
    vm.expectRevert(abi.encodeWithSignature(
      "RequestIdentifierMismatch(uint256,uint256)",
      incorrectRequestIdentifier,
      correctRequestIdentifier
      ));
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyXMismatchWithClaim(uint256 incorrectCommitmentMapperPubKeyX) public {
    // we assume that the incorrectCommitmentMapperPubKeyX is different from the correct commitmentMapperPubKeyX when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyX != hydraS2Proofs.getEdDSAPubKeyDevBeta()[0]);
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    // commitmentMapperPubKeyX is at index 2 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 2, incorrectCommitmentMapperPubKeyX);
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyYMismatchWithClaim(uint256 incorrectCommitmentMapperPubKeyY) public {
    // we assume that the incorrectCommitmentMapperPubKeyY is different from the correct commitmentMapperPubKeyY when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyY != hydraS2Proofs.getEdDSAPubKeyDevBeta()[1]);
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    // commitmentMapperPubKeyY is at index 3 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 3, incorrectCommitmentMapperPubKeyY); 
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKeyDevBeta()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function test_RevertWith_SourceVerificationNotEnabled() public {
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    // we change the sourceVerificationEnabled to be equal to false instead of true
    // sourceVerificationEnabled is at index 12 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 12, uint256(0));
    vm.expectRevert(abi.encodeWithSignature("SourceVerificationNotEnabled()"));
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_AccountsTreeValueMismatch(uint256 incorrectAccountsTreeValue) public {
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    uint256 correctAccountsTreeValue = abi.decode(invalidResponse.proofs[0].proofData, (HydraS2ProofData))._getAccountsTreeValue();
    // we assume that the incorrectAccountsTreeValue is different from the correct accountsTreeValue when fuzzing
    vm.assume(incorrectAccountsTreeValue != correctAccountsTreeValue);
    // accountsTreeValue is at index 8 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 8, incorrectAccountsTreeValue);
    vm.expectRevert(
      abi.encodeWithSignature(
        "AccountsTreeValueMismatch(uint256,uint256)",
        incorrectAccountsTreeValue,
        correctAccountsTreeValue
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function test_RevertWith_ClaimTypeMismatch() public {
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    // we change the claimComparator to be equal to 1, the claimType should be EQ to not revert
    // but we keep the claimType of GTE in the claimRequest
    uint256 incorrectClaimComparator = 1;
    // claimComparator is at index 9 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 9, incorrectClaimComparator); 
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeMismatch(uint256,uint256)",
        incorrectClaimComparator,
        claimRequest.claimType
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_InvalidExtraData(uint256 incorrectExtraData) public {
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    uint256 correctExtraData = abi.decode(invalidResponse.proofs[0].proofData, (HydraS2ProofData))._getExtraData();
    // we assume that the incorrectExtraData is different from the correct extraData when fuzzing
    vm.assume(incorrectExtraData != correctExtraData);
    // extraData is at index 1 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 1, incorrectExtraData);
    vm.expectRevert(
      abi.encodeWithSignature(
        "InvalidExtraData(uint256,uint256)",
        incorrectExtraData,
        correctExtraData
      )
    );
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  function testFuzz_RevertWith_InvalidProof(uint256 incorrectProofIdentifier) public {
    (SismoConnectResponse memory invalidResponse,) = hydraS2Proofs.getResponseWithOneClaimAndSignature(commitmentMapperRegistry);
    uint256 correctProofIdentifier = abi.decode(invalidResponse.proofs[0].proofData, (HydraS2ProofData))._getProofIdentifier();
    vm.assume(incorrectProofIdentifier != correctProofIdentifier);
    // we force the incorrectProofIdentifier to be less than the SNARK_FIELD
    vm.assume(incorrectProofIdentifier < HydraS2Lib.SNARK_FIELD);
     // proofIdentifier is at index 6 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 6, incorrectProofIdentifier);
    vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
    sismoConnect.exposed_verify({responseBytes: abi.encode(invalidResponse), claim: claimRequest, signature: signature});
  }

  ///////////////////////////
  // Helper functions
  ///////////////////////////


  // this helper function is used to change the input at the specified index of the snark proof in the response
  // the value is the new value of the input at the specified index
  function _changeProofDataInSismoConnectResponse(SismoConnectResponse memory response, uint256 index, uint256 value) internal returns (SismoConnectResponse memory) {
    // Decode the snark proof from the sismoConnectProof
    // This snark proof is specify to this proving scheme
    snarkProof = abi.decode(response.proofs[0].proofData, (HydraS2ProofData));
    // we change the input at the specified index to be different
    snarkProof.input[index] = value; 
    response.proofs[0].proofData = abi.encode(snarkProof);
    return response;
  }

  function _encodeRequestIdentifier(
    bytes16 _groupId,
    bytes16 groupTimestamp,
    bytes16 _appId,
    bytes16 namespace
  ) internal pure returns (uint256) {
    bytes32 groupSnapshotId = bytes32(abi.encodePacked(_groupId, groupTimestamp));
    bytes32 serviceId = bytes32(abi.encodePacked(_appId, namespace));
    return
      uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % HydraS2Lib.SNARK_FIELD;
  }
}
