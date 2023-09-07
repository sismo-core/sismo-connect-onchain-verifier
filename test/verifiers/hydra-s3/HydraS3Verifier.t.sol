// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS3BaseTest} from "./HydraS3BaseTest.t.sol";
import {HydraS3ProofData, HydraS3Lib, HydraS3ProofInput} from "src/verifiers/HydraS3Lib.sol";
import {ClaimBuilder} from "src/utils/ClaimBuilder.sol";
import {AuthBuilder} from "src/utils/AuthBuilder.sol";
import "src/utils/Structs.sol";

contract HydraS3VerifierTest is HydraS3BaseTest {
  using HydraS3Lib for HydraS3ProofData;
  using ClaimBuilder for bytes16;
  using AuthBuilder for uint8;

  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;
  bytes16 constant DEFAULT_APP_ID = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 constant DEFAULT_GROUP_ID = 0xe9ed316946d3d98dfcd829a53ec9822e;
  bytes16 constant DEFAULT_GROUP_TIMESTAMP = bytes16("latest");
  bytes16 public DEFAULT_NAMESPACE = bytes16(keccak256("main"));
  bool public DEFAULT_IS_IMPERSONATION_MODE = false;

  HydraS3ProofData snarkProof;

  SignatureRequest public DEFAULT_SIGNATURE_REQUEST =
    SignatureRequest({message: abi.encode(user), isSelectableByUser: false, extraData: ""});

  function setUp() public virtual override {
    HydraS3BaseTest.setUp();
  }

  function test_RevertWith_InvalidVersionOfProvingScheme() public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    invalidResponse.proofs[0].provingScheme = bytes32("fake-proving-scheme");

    vm.expectRevert(
      abi.encodeWithSignature("InvalidVersion(bytes32)", bytes32("fake-proving-scheme"))
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function test_RevertWith_OnlyOneAuthAndOneClaimIsSupported() public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimOneAuthAndOneMessage();

    Auth[] memory auths = new Auth[](2);
    // take the first auth from the valid response
    auths[0] = invalidResponse.proofs[1].auths[0];
    // we add a second auth to the proof
    auths[1] = AuthBuilder.build({authType: AuthType.VAULT});

    Claim[] memory claims = new Claim[](2);
    claims[0] = invalidResponse.proofs[0].claims[0];
    // we add a second claim to the proof
    claims[1] = ClaimBuilder.build({groupId: DEFAULT_GROUP_ID});

    invalidResponse.proofs[0] = SismoConnectProof({
      provingScheme: invalidResponse.proofs[0].provingScheme,
      auths: auths,
      claims: claims,
      proofData: invalidResponse.proofs[0].proofData,
      extraData: ""
    });

    vm.expectRevert(abi.encodeWithSignature("OnlyOneAuthAndOneClaimIsSupported()"));
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_VaultNamespaceMismatch(uint256 invalidVaultNamespace) public {
    // we force the invalidVaultNamespace to be different from the correct one
    // while being a valid uint128
    vm.assume(invalidVaultNamespace < 2 ** 128 - 1);
    vm.assume(
      invalidVaultNamespace !=
        uint256(keccak256(abi.encodePacked(DEFAULT_APP_ID, bytes16(0)))) % HydraS3Lib.SNARK_FIELD
    );
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOnlyOneAuthAndMessage();
    // we change the vaultNamespace to be equal to a random one instead of the coorect appId
    // vaultNamespace is at index 11 is in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      11,
      invalidVaultNamespace
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "VaultNamespaceMismatch(uint256,uint256)",
        snarkProof._getVaultNamespace(),
        uint256(keccak256(abi.encodePacked(DEFAULT_APP_ID, bytes16(0)))) % HydraS3Lib.SNARK_FIELD
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function test_RevertWith_DestinationVerificationNotEnabled() public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOnlyOneAuthAndMessage();
    // we change the authType to be equal to GITHUB instead of ANON
    invalidResponse.proofs[0].auths[0] = Auth({
      authType: AuthType.GITHUB,
      isAnon: false,
      isSelectableByUser: true,
      userId: 0,
      extraData: ""
    });

    // this should revert because the destinationVerificationEnabled is false and the AuthType is different from VAULT
    vm.expectRevert(abi.encodeWithSignature("DestinationVerificationNotEnabled()"));
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyXMismatchWithAuth(
    uint256 incorrectCommitmentMapperPubKeyX
  ) public {
    // we assume that the incorrectCommitmentMapperPubKeyX is different from the correct commitmentMapperPubKeyX when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyX != hydraS3Proofs.getEdDSAPubKey()[0]);
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOnlyOneAuthAndMessage();
    // we change the authType to be equal to GITHUB instead of ANON to be able to check the  public key
    invalidResponse.proofs[0].auths[0] = Auth({
      authType: AuthType.GITHUB,
      isAnon: false,
      isSelectableByUser: true,
      userId: 0,
      extraData: ""
    });
    // we change the commitmentMapperPubKeyX to be equal to a random uint256 instead of the correct commitmentMapperPubKeyX
    // commitmentMapperPubKeyX is at index 2 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      2,
      incorrectCommitmentMapperPubKeyX
    );
    // we change the destinationVerificationEnabled to be equal to true instead of false
    // with an AuthType different from ANON, the destinationVerificationEnabled should be true
    // destinationVerificationEnabled at index 13 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 13, uint256(1)); // true

    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS3Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS3Proofs.getEdDSAPubKey()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyYMismatchWithAuth(
    uint256 incorrectCommitmentMapperPubKeyY
  ) public {
    // we assume that the incorrectCommitmentMapperPubKeyY is different from the correct commitmentMapperPubKeyY when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyY != hydraS3Proofs.getEdDSAPubKey()[1]);
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOnlyOneAuthAndMessage();
    // we change the authType to be equal to GITHUB instead of ANON to be able to check the  public key
    invalidResponse.proofs[0].auths[0] = Auth({
      authType: AuthType.GITHUB,
      isAnon: false,
      isSelectableByUser: true,
      userId: 0,
      extraData: ""
    });
    // we change the commitmentMapperPubKeyY to be equal to a random uint256 instead of the correct commitmentMapperPubKeyY
    // commitmentMapperPubKeyY is at index 3 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      3,
      incorrectCommitmentMapperPubKeyY
    );
    // we change the destinationVerificationEnabled to be equal to true instead of false
    // with an AuthType different from ANON, the destinationVerificationEnabled should be true
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 13, uint256(1)); // destinationVerificationEnabled at index 13 is equal to true

    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS3Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS3Proofs.getEdDSAPubKey()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_ClaimValueMismatch(uint256 invalidClaimValue) public {
    // we force that the invalidClaimValue is different from the correct claimValue when fuzzing
    vm.assume(invalidClaimValue != 1);
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    // claimValue is at index 7 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 7, invalidClaimValue);
    vm.expectRevert(abi.encodeWithSignature("ClaimValueMismatch()"));
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_RequestIdentifierMismatch(
    uint256 incorrectRequestIdentifier
  ) public {
    uint256 correctRequestIdentifier = _encodeRequestIdentifier(
      DEFAULT_GROUP_ID,
      DEFAULT_GROUP_TIMESTAMP,
      DEFAULT_APP_ID,
      DEFAULT_NAMESPACE
    );
    // we force that the incorrectRequestIdentifier is different from the correct requestIdentifier when fuzzing
    vm.assume(incorrectRequestIdentifier != correctRequestIdentifier);
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    // requestIdentifier is at index 5 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      5,
      incorrectRequestIdentifier
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "RequestIdentifierMismatch(uint256,uint256)",
        incorrectRequestIdentifier,
        correctRequestIdentifier
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyXMismatchWithClaim(
    uint256 incorrectCommitmentMapperPubKeyX
  ) public {
    // we assume that the incorrectCommitmentMapperPubKeyX is different from the correct commitmentMapperPubKeyX when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyX != hydraS3Proofs.getEdDSAPubKey()[0]);
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    // commitmentMapperPubKeyX is at index 2 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      2,
      incorrectCommitmentMapperPubKeyX
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS3Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS3Proofs.getEdDSAPubKey()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });

    // it should also revert when impersonation mode is set to true
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS3Proofs.getImpersonationEdDSAPubKey()[0]),
        bytes32(hydraS3Proofs.getImpersonationEdDSAPubKey()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: true,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_CommitmentMapperPubKeyYMismatchWithClaim(
    uint256 incorrectCommitmentMapperPubKeyY
  ) public {
    // we assume that the incorrectCommitmentMapperPubKeyY is different from the correct commitmentMapperPubKeyY when fuzzing
    vm.assume(incorrectCommitmentMapperPubKeyY != hydraS3Proofs.getEdDSAPubKey()[1]);
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    // commitmentMapperPubKeyY is at index 3 in the snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      3,
      incorrectCommitmentMapperPubKeyY
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS3Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS3Proofs.getEdDSAPubKey()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });

    // it should also revert when impersonation mode is set to true
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS3Proofs.getImpersonationEdDSAPubKey()[0]),
        bytes32(hydraS3Proofs.getImpersonationEdDSAPubKey()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: true,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function test_RevertWith_SourceVerificationNotEnabled() public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    // we change the sourceVerificationEnabled to be equal to false instead of true
    // sourceVerificationEnabled is at index 12 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(invalidResponse, 12, uint256(0));
    vm.expectRevert(abi.encodeWithSignature("SourceVerificationNotEnabled()"));
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_RegistryTreeRootNotAvailable(
    uint256 invalidRegistryTreeRoot
  ) public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();

    // we shift the return of the mocked AvailableRootsregistry contract to be always false
    availableRootsRegistry.switchIsRootAvailable();
    // registryTreeRoot is at index 4 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      4,
      invalidRegistryTreeRoot
    );
    vm.expectRevert(
      abi.encodeWithSignature("RegistryRootNotAvailable(uint256)", invalidRegistryTreeRoot)
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_AccountsTreeValueMismatch(
    uint256 incorrectAccountsTreeValue
  ) public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    uint256 correctAccountsTreeValue = abi
      .decode(invalidResponse.proofs[0].proofData, (HydraS3ProofData))
      ._getAccountsTreeValue();
    // we assume that the incorrectAccountsTreeValue is different from the correct accountsTreeValue when fuzzing
    vm.assume(incorrectAccountsTreeValue != correctAccountsTreeValue);
    // accountsTreeValue is at index 8 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      8,
      incorrectAccountsTreeValue
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "AccountsTreeValueMismatch(uint256,uint256)",
        incorrectAccountsTreeValue,
        correctAccountsTreeValue
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function test_RevertWith_ClaimTypeMismatch() public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    // we change the claimComparator to be equal to 1 in the proof, the claimType should be EQ to not revert
    // but we keep the claimType of GTE in the claim
    uint256 incorrectClaimComparator = 1;
    // claimComparator is at index 9 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      9,
      incorrectClaimComparator
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeMismatch(uint256,uint256)",
        incorrectClaimComparator,
        invalidResponse.proofs[0].claims[0].claimType
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_InvalidExtraData(uint256 incorrectExtraData) public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    uint256 correctExtraData = abi
      .decode(invalidResponse.proofs[0].proofData, (HydraS3ProofData))
      ._getExtraData();
    // we assume that the incorrectExtraData is different from the correct extraData when fuzzing
    vm.assume(incorrectExtraData != correctExtraData);
    // extraData is at index 1 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      1,
      incorrectExtraData
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "InvalidExtraData(uint256,uint256)",
        incorrectExtraData,
        correctExtraData
      )
    );
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  function testFuzz_RevertWith_InvalidProof(uint256 incorrectProofIdentifier) public {
    (SismoConnectResponse memory invalidResponse, ) = hydraS3Proofs
      .getResponseWithOneClaimAndSignature();
    uint256 correctProofIdentifier = abi
      .decode(invalidResponse.proofs[0].proofData, (HydraS3ProofData))
      ._getProofIdentifier();
    vm.assume(incorrectProofIdentifier != correctProofIdentifier);
    // we force the incorrectProofIdentifier to be less than the SNARK_FIELD
    vm.assume(incorrectProofIdentifier < HydraS3Lib.SNARK_FIELD);
    // proofIdentifier is at index 6 in snarkProof's inputs
    invalidResponse = _changeProofDataInSismoConnectResponse(
      invalidResponse,
      6,
      incorrectProofIdentifier
    );
    vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
    hydraS3Verifier.verify({
      appId: DEFAULT_APP_ID,
      namespace: DEFAULT_NAMESPACE,
      isImpersonationMode: DEFAULT_IS_IMPERSONATION_MODE,
      signedMessage: DEFAULT_SIGNATURE_REQUEST.message,
      sismoConnectProof: invalidResponse.proofs[0]
    });
  }

  ///////////////////////////
  // Helper functions
  ///////////////////////////

  // this helper function is used to change the input at the specified index of the snark proof in the response
  // the value is the new value of the input at the specified index
  function _changeProofDataInSismoConnectResponse(
    SismoConnectResponse memory response,
    uint256 index,
    uint256 value
  ) internal returns (SismoConnectResponse memory) {
    // Decode the snark proof from the sismoConnectProof
    // This snark proof is specify to this proving scheme
    snarkProof = abi.decode(response.proofs[0].proofData, (HydraS3ProofData));
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
      uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % HydraS3Lib.SNARK_FIELD;
  }
}
