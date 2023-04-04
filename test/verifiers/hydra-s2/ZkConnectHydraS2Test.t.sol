// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import "test/mocks/ZkConnectTest.sol";
import "src/libs/zk-connect/ZkConnectLib.sol";
import {HydraS2ProofData, HydraS2Lib, HydraS2ProofInput} from "src/verifiers/HydraS2Lib.sol";

contract ZkConnectHydraS2Test is HydraS2BaseTest {
  using HydraS2Lib for HydraS2ProofData;

  ZkConnectTest zkConnect;
  address user = 0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE;
  bytes16 constant appId = 0x11b1de449c6c4adb0b5775b3868b28b3;
  bytes16 constant groupId = 0xe9ed316946d3d98dfcd829a53ec9822e;
  Claim claimRequest;
  Auth authRequest;
  bytes messageSignatureRequest;

  HydraS2ProofData snarkProof;

  function setUp() public virtual override {
    super.setUp();
    zkConnect = new ZkConnectTest(appId);
    claimRequest = zkConnect.buildClaimTest({groupId: groupId});
    authRequest = zkConnect.buildAuthTest({authType: AuthType.ANON});
    messageSignatureRequest = abi.encode(user);
  }

  function test_RevertWith_InvalidVersionOfProvingScheme() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    invalidZkConnectResponse.proofs[0].provingScheme = bytes32("fake-proving-scheme");
    // register the fake proving scheme to the HydraS2Verifier address i the ZkConnectVerifier contract
    // if the proving scheme is not registered, it will revert without an error since the ZkConnectVerifier will not be able to find the verifier when routing
    vm.prank(owner);
    zkConnectVerifier.registerVerifier(
      bytes32("fake-proving-scheme"),
      address(hydraS2Verifier)
    );
    vm.expectRevert(
      abi.encodeWithSignature(
        "InvalidVersion(bytes32)",
        bytes32("fake-proving-scheme")
      )
    );
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_VaultNamespaceMismatch() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse2();

    // we change the vaultNamespace to be equal 1 instead of the appId
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 11, uint256(1));
    vm.expectRevert(
      abi.encodeWithSignature(
        "VaultNamespaceMismatch(bytes16,bytes16)",
        bytes16(uint128(snarkProof._getVaultNamespace())),
        appId
      )
    );
    zkConnect.verifyAuthAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), authRequest: authRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_DestinationVerificationNotEnabled() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse2();
    // we change the authType to be equal to GITHUB instead of ANON
    invalidZkConnectResponse.proofs[0].auth = Auth({authType: AuthType.GITHUB, anonMode: false, userId: 0, extraData: ""});

    // we change the authType to be equal to GITHUB instead of ANON, so it is the same as in the zkConnectResponse and we can test the revert of the destinationVerificationEnabled
    Auth memory githubAuthRequest = zkConnect.buildAuthTest({authType: AuthType.GITHUB});

    // this should revert because the destinationVerificationEnabled is false and the AuthType is different from ANON
    vm.expectRevert(abi.encodeWithSignature("DestinationVerificationNotEnabled()"));
    zkConnect.verifyAuthAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), authRequest: githubAuthRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_CommitmentMapperPubKeyXMismatchWithAuth() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse2();
    // we change the authType to be equal to GITHUB instead of ANON to be able to check the commitmentMapperRegistry public key
    invalidZkConnectResponse.proofs[0].auth = Auth({authType: AuthType.GITHUB, anonMode: false, userId: 0, extraData: ""});
    // we change the commitmentMapperPubKeyX to be equal to 1 instead of the correct commitmentMapperPubKeyX
    uint256 incorrectCommitmentMapperPubKeyX = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 2, incorrectCommitmentMapperPubKeyX); // commitmentMapperPubKeyX at index 2 is equal to 1
    // we change the destinationVerificationEnabled to be equal to true instead of false
    // with an AuthType different from ANON, the destinationVerificationEnabled should be true
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 13, uint256(1)); // destinationVerificationEnabled at index 13 is equal to true

    // we change the authType to be equal to GITHUB instead of ANON, so it is the same as in the zkConnectResponse and we can test the revert of the destinationVerificationEnabled
    Auth memory githubAuthRequest = zkConnect.buildAuthTest({authType: AuthType.GITHUB});
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKey()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    zkConnect.verifyAuthAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), authRequest: githubAuthRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_CommitmentMapperPubKeyYMismatchWithAuth() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse2();
    // we change the authType to be equal to GITHUB instead of ANON to be able to check the commitmentMapperRegistry public key
    invalidZkConnectResponse.proofs[0].auth = Auth({authType: AuthType.GITHUB, anonMode: false, userId: 0, extraData: ""});
    // we change the commitmentMapperPubKeyY to be equal to 1 instead of the correct commitmentMapperPubKeyY
    uint256 incorrectCommitmentMapperPubKeyY = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 3, incorrectCommitmentMapperPubKeyY); // commitmentMapperPubKeyY at index 3 is equal to 1
    // we change the destinationVerificationEnabled to be equal to true instead of false
    // with an AuthType different from ANON, the destinationVerificationEnabled should be true
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 13, uint256(1)); // destinationVerificationEnabled at index 13 is equal to true

    // we change the authType to be equal to GITHUB instead of ANON, so it is the same as in the zkConnectResponse and we can test the revert of the destinationVerificationEnabled
    Auth memory githubAuthRequest = zkConnect.buildAuthTest({authType: AuthType.GITHUB});
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKey()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    zkConnect.verifyAuthAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), authRequest: githubAuthRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_ClaimValueMismatch() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 7, uint256(10)); // claimValue at index 7 is equal to 10

    vm.expectRevert(abi.encodeWithSignature("ClaimValueMismatch()"));
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_RequestIdentifierMismatch() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 5, uint256(8)); // requestIdentifier at index 5 is equal to 8
    vm.expectRevert(abi.encodeWithSignature(
      "RequestIdentifierMismatch(uint256,uint256)",
      snarkProof._getRequestIdentifier(),
      _encodeRequestIdentifier(groupId, bytes16("latest"), appId, bytes16(keccak256("main")))
      ));
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_CommitmentMapperPubKeyXMismatchWithClaim() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the commitmentMapperPubKeyX to be equal to 1 instead of the correct commitmentMapperPubKeyX
    uint256 incorrectCommitmentMapperPubKeyX = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 2, incorrectCommitmentMapperPubKeyX); // commitmentMapperPubKeyX at index 2 is equal to 1
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKey()[1]),
        bytes32(incorrectCommitmentMapperPubKeyX),
        bytes32(snarkProof._getCommitmentMapperPubKey()[1])
      )
    );
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_CommitmentMapperPubKeyYMismatchWithClaim() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the commitmentMapperPubKeyX to be equal to 1 instead of the correct commitmentMapperPubKeyX
    uint256 incorrectCommitmentMapperPubKeyY = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 3, incorrectCommitmentMapperPubKeyY); // commitmentMapperPubKeyX at index 2 is equal to 1
    vm.expectRevert(
      abi.encodeWithSignature(
        "CommitmentMapperPubKeyMismatch(bytes32,bytes32,bytes32,bytes32)",
        bytes32(hydraS2Proofs.getEdDSAPubKey()[0]),
        bytes32(hydraS2Proofs.getEdDSAPubKey()[1]),
        bytes32(snarkProof._getCommitmentMapperPubKey()[0]),
        bytes32(incorrectCommitmentMapperPubKeyY)
      )
    );
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWIth_SourceVerificationNotEnabled() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the sourceVerificationEnabled to be equal to false instead of true
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 12, uint256(0)); // sourceVerificationEnabled at index 12 is equal to false
    vm.expectRevert(abi.encodeWithSignature("SourceVerificationNotEnabled()"));
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_AccountsTreeValueMismatch() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the accountsTreeValue to be equal to 1 instead of the correct accountsTreeValue
    uint256 incorrectAccountsTreeValue = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 8, incorrectAccountsTreeValue); // accountsTreeValue at index 8 is equal to 1
    vm.expectRevert(
      abi.encodeWithSignature(
        "AccountsTreeValueMismatch(uint256,uint256)",
        incorrectAccountsTreeValue,
        abi.decode(hydraS2Proofs.getZkConnectResponse1().proofs[0].proofData, (HydraS2ProofData))._getAccountsTreeValue()
      )
    );
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_ClaimTypeMismatch() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the claimComparator to be equal to 1, the claimType should be EQ to not revert
    // but we keep the claimType of GTE in the claimRequest
    uint256 incorrectClaimComparator = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 9, incorrectClaimComparator); // claimComparator at index 9 is equal to 1
    vm.expectRevert(
      abi.encodeWithSignature(
        "ClaimTypeMismatch(uint256,uint256)",
        incorrectClaimComparator,
        claimRequest.claimType
      )
    );
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_InvalidExtraData() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the extraData to be equal to 1 instead of the correct extraData
    uint256 incorrectExtraData = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 1, incorrectExtraData); // extraData at index 1 is equal to 1
    vm.expectRevert(
      abi.encodeWithSignature(
        "InvalidExtraData(uint256,uint256)",
        incorrectExtraData,
        abi.decode(hydraS2Proofs.getZkConnectResponse1().proofs[0].proofData, (HydraS2ProofData))._getExtraData()
      )
    );
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});
  }

  function test_RevertWith_InvalidProof() public {
    ZkConnectResponse memory invalidZkConnectResponse = hydraS2Proofs.getZkConnectResponse1();
    // we change the proof identifier to trigger the invalid proof revert
    uint256 incorrectProofIdentifier = 1;
    invalidZkConnectResponse = _changeProofDataInZkConnectResponse(invalidZkConnectResponse, 6, incorrectProofIdentifier); // proofIdentifier at index 6 is equal to 1
    vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
    zkConnect.verifyClaimAndMessageTest({responseBytes: abi.encode(invalidZkConnectResponse), claimRequest: claimRequest, messageSignatureRequest: messageSignatureRequest});

  }

  ///////////////////////////
  // Helper functions
  ///////////////////////////


  // this helper function is used to change the input at the specified index of the snark proof in the zkConnectResponse
  // the value is the new value of the input at the specified index
  function _changeProofDataInZkConnectResponse(ZkConnectResponse memory zkConnectResponse, uint256 index, uint256 value) internal returns (ZkConnectResponse memory) {
    // Decode the snark proof from the zkConnectProof
    // This snark proof is specify to this proving scheme
    snarkProof = abi.decode(zkConnectResponse.proofs[0].proofData, (HydraS2ProofData));
    // we change the input at the specified index to be different
    snarkProof.input[index] = value; 
    zkConnectResponse.proofs[0].proofData = abi.encode(snarkProof);
    return zkConnectResponse;
  }

  function _encodeRequestIdentifier(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes16 _appId,
    bytes16 namespace
  ) internal pure returns (uint256) {
    bytes32 groupSnapshotId = bytes32(abi.encodePacked(groupId, groupTimestamp));
    bytes32 serviceId = bytes32(abi.encodePacked(_appId, namespace));
    return
      uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % HydraS2Lib.SNARK_FIELD;
  }
}
