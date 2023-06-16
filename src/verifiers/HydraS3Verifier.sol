// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IBaseVerifier} from "../interfaces/IBaseVerifier.sol";
import {IHydraS3Verifier} from "./IHydraS3Verifier.sol";
import {HydraS3Verifier as HydraS3SnarkVerifier} from "@sismo-core/hydra-s3/HydraS3Verifier.sol";
import {ICommitmentMapperRegistry} from "../periphery/interfaces/ICommitmentMapperRegistry.sol";
import {IAvailableRootsRegistry} from "../periphery/interfaces/IAvailableRootsRegistry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {HydraS3ProofData, HydraS3Lib, HydraS3ProofInput} from "./HydraS3Lib.sol";
import {Auth, ClaimType, AuthType, Claim, SismoConnectProof, VerifiedAuth, VerifiedClaim} from "src/libs/utils/Structs.sol";

contract HydraS3Verifier is IHydraS3Verifier, IBaseVerifier, HydraS3SnarkVerifier, Initializable {
  using HydraS3Lib for HydraS3ProofData;
  using HydraS3Lib for Auth;
  using HydraS3Lib for Claim;

  // Struct holding the decoded Hydra-S3 snark proof and decoded public inputs
  // This struct is used to avoid stack too deep error
  struct HydraS3Proof {
    HydraS3ProofData data;
    HydraS3ProofInput input;
  }

  // Struct holding the verified Auth and Claim from the Hydra-S3 snark proof
  // This struct is used to avoid stack too deep error
  struct VerifiedProof {
    VerifiedAuth auth;
    VerifiedClaim claim;
  }

  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable HYDRA_S3_VERSION = "hydra-s3.1";
  // Registry storing the Commitment Mapper EdDSA Public key
  ICommitmentMapperRegistry public immutable COMMITMENT_MAPPER_REGISTRY;
  // Registry storing the Registry Tree Roots of the Attester's available ClaimData
  IAvailableRootsRegistry public immutable AVAILABLE_ROOTS_REGISTRY;

  constructor(address commitmentMapperRegistry, address availableRootsRegistry) {
    COMMITMENT_MAPPER_REGISTRY = ICommitmentMapperRegistry(commitmentMapperRegistry);
    AVAILABLE_ROOTS_REGISTRY = IAvailableRootsRegistry(availableRootsRegistry);
    initialize();
  }

  function initialize() public reinitializer(IMPLEMENTATION_VERSION) {}

  function verify(
    bytes16 appId,
    bytes16 namespace,
    bool isImpersonationMode,
    bytes memory signedMessage,
    SismoConnectProof memory sismoConnectProof
  ) external returns (VerifiedAuth memory, VerifiedClaim memory) {
    // Verify the sismoConnectProof version corresponds to the current verifier.
    if (sismoConnectProof.provingScheme != HYDRA_S3_VERSION) {
      revert InvalidVersion(sismoConnectProof.provingScheme);
    }

    HydraS3Proof memory hydraS3Proof = HydraS3Proof({
      // Decode the snark proof data from the sismoConnectProof
      data: abi.decode(sismoConnectProof.proofData, (HydraS3ProofData)),
      // Get the public inputs from the snark proof data
      input: abi.decode(sismoConnectProof.proofData, (HydraS3ProofData))._input()
    });

    // We only support one Auth and one Claim in the hydra-s3 proving scheme
    // We revert if there is more than one Auth or Claim in the sismoConnectProof
    if (sismoConnectProof.auths.length > 1 || sismoConnectProof.claims.length > 1) {
      revert OnlyOneAuthAndOneClaimIsSupported();
    }

    // Verify Claim, Auth and SignedMessage validity by checking corresponding
    // snarkProof public input
    VerifiedProof memory verifiedProof;
    if (sismoConnectProof.auths.length == 1) {
      // Get the Auth from the sismoConnectProof
      // We only support one Auth in the hydra-s3 proving scheme
      Auth memory auth = sismoConnectProof.auths[0];
      verifiedProof.auth = _verifyAuthValidity(
        hydraS3Proof.input,
        sismoConnectProof.proofData,
        auth,
        appId
      );
    }
    if (sismoConnectProof.claims.length == 1) {
      // Get the Claim from the sismoConnectProof
      // We only support one Claim in the hydra-s3 proving scheme
      Claim memory claim = sismoConnectProof.claims[0];
      verifiedProof.claim = _verifyClaimValidity(
        hydraS3Proof.input,
        sismoConnectProof.proofData,
        claim,
        appId,
        namespace,
        isImpersonationMode
      );
    }

    _validateSignedMessageInput(hydraS3Proof.input, signedMessage);

    // Check the snarkProof is valid
    _checkSnarkProof(hydraS3Proof.data);
    return (verifiedProof.auth, verifiedProof.claim);
  }

  function _verifyClaimValidity(
    HydraS3ProofInput memory input,
    bytes memory proofData,
    Claim memory claim,
    bytes16 appId,
    bytes16 namespace,
    bool isImpersonationMode
  ) private view returns (VerifiedClaim memory) {
    // Check claim value validity
    if (input.claimValue != claim.value) {
      revert ClaimValueMismatch();
    }

    // Check requestIdentifier validity
    uint256 expectedRequestIdentifier = _encodeRequestIdentifier(
      claim.groupId,
      claim.groupTimestamp,
      appId,
      namespace
    );
    if (input.requestIdentifier != expectedRequestIdentifier) {
      revert RequestIdentifierMismatch(input.requestIdentifier, expectedRequestIdentifier);
    }

    // commitmentMapperPubKey
    // In impersonation mode, we use the EdDSA public key of the Impersonation Commitment Mapper
    // otherwise we use the EdDSA public key of the Commitment Mapper Registry
    uint256[2] memory commitmentMapperPubKey = isImpersonationMode
      ? [
        0x1801b584700a740f9576cc7e83745895452edc518a9ce60b430e1272fc4eb93b,
        0x057cf80de4f8dd3e4c56f948f40c28c3acbeca71ef9f825597bf8cc059f1238b
      ]
      : COMMITMENT_MAPPER_REGISTRY.getEdDSAPubKey();

    if (
      input.commitmentMapperPubKey[0] != commitmentMapperPubKey[0] ||
      input.commitmentMapperPubKey[1] != commitmentMapperPubKey[1]
    ) {
      revert CommitmentMapperPubKeyMismatch(
        bytes32(commitmentMapperPubKey[0]),
        bytes32(commitmentMapperPubKey[1]),
        bytes32(input.commitmentMapperPubKey[0]),
        bytes32(input.commitmentMapperPubKey[1])
      );
    }

    // sourceVerificationEnabled
    if (input.sourceVerificationEnabled == false) {
      revert SourceVerificationNotEnabled();
    }
    // isRootAvailable
    if (!AVAILABLE_ROOTS_REGISTRY.isRootAvailable(input.registryTreeRoot)) {
      revert RegistryRootNotAvailable(input.registryTreeRoot);
    }
    // accountsTreeValue
    uint256 groupSnapshotId = _encodeAccountsTreeValue(claim.groupId, claim.groupTimestamp);
    if (input.accountsTreeValue != groupSnapshotId) {
      revert AccountsTreeValueMismatch(input.accountsTreeValue, groupSnapshotId);
    }

    bool claimComparatorEQ = input.claimComparator == 1;
    bool isClaimTypeFromClaimEqualToEQ = claim.claimType == ClaimType.EQ;
    if (claimComparatorEQ != isClaimTypeFromClaimEqualToEQ) {
      revert ClaimTypeMismatch(input.claimComparator, uint256(claim.claimType));
    }

    return
      VerifiedClaim({
        groupId: claim.groupId,
        groupTimestamp: claim.groupTimestamp,
        value: claim.value,
        claimType: claim.claimType,
        proofId: input.proofIdentifier,
        proofData: proofData,
        extraData: claim.extraData
      });
  }

  function _verifyAuthValidity(
    HydraS3ProofInput memory input,
    bytes memory proofData,
    Auth memory auth,
    bytes16 appId
  ) private view returns (VerifiedAuth memory) {
    uint256 userIdFromProof;
    if (auth.authType == AuthType.VAULT) {
      // vaultNamespace validity
      uint256 vaultNamespaceFromProof = input.vaultNamespace;
      uint256 expectedVaultNamespace = _encodeVaultNamespace(appId);
      if (vaultNamespaceFromProof != expectedVaultNamespace) {
        revert VaultNamespaceMismatch(vaultNamespaceFromProof, expectedVaultNamespace);
      }
      userIdFromProof = input.vaultIdentifier;
    } else {
      if (input.destinationVerificationEnabled == false) {
        revert DestinationVerificationNotEnabled();
      }
      // commitmentMapperPubKey
      uint256[2] memory commitmentMapperPubKey = COMMITMENT_MAPPER_REGISTRY.getEdDSAPubKey();
      if (
        input.commitmentMapperPubKey[0] != commitmentMapperPubKey[0] ||
        input.commitmentMapperPubKey[1] != commitmentMapperPubKey[1]
      ) {
        revert CommitmentMapperPubKeyMismatch(
          bytes32(commitmentMapperPubKey[0]),
          bytes32(commitmentMapperPubKey[1]),
          bytes32(input.commitmentMapperPubKey[0]),
          bytes32(input.commitmentMapperPubKey[1])
        );
      }
      userIdFromProof = uint256(uint160(input.destinationIdentifier));
      _checkSismoIdentifierValidity(userIdFromProof, auth.authType);
    }

    // check that the userId from the proof is the same as the userId in the auth
    // the userId in the proof is the vaultIdentifier for AuthType.VAULT and the destinationIdentifier for other Auth types
    if (
      auth.userId != userIdFromProof && !auth.isSelectableByUser // we do NOT check the userId if it has been made selectable by user in the vault app
    ) {
      revert UserIdMismatch(userIdFromProof, auth.userId);
    }

    return
      VerifiedAuth({
        authType: auth.authType,
        isAnon: auth.isAnon,
        userId: userIdFromProof,
        extraData: auth.extraData,
        proofData: proofData
      });
  }

  function _validateSignedMessageInput(
    HydraS3ProofInput memory input,
    bytes memory signedMessage
  ) private pure {
    // don't check extraData if signedMessage from response is empty
    if (keccak256(signedMessage) == keccak256(abi.encode(0x00))) {
      return;
    }
    if (input.extraData != uint256(keccak256(signedMessage)) % HydraS3Lib.SNARK_FIELD) {
      revert InvalidExtraData(
        input.extraData,
        uint256(keccak256(signedMessage)) % HydraS3Lib.SNARK_FIELD
      );
    }
  }

  function _checkSismoIdentifierValidity(uint256 userId, AuthType authType) private pure {
    // the userId is 160 bits long (20 bytes), since it has the format of an evm address
    if (authType == AuthType.GITHUB) {
      // check that the userId starts with 0x1001 -> sismoIdentifier for dataSource GITHUB
      // 160 bits - 16 bits = 144 bits
      // we check that the first 16 bits are equal to 0x1001
      if ((userId) >> 144 != 0x1001) {
        revert InvalidSismoIdentifier(bytes32(userId), uint8(authType));
      }
    }
    if (authType == AuthType.TWITTER) {
      // check that the userId starts with 0x1002 -> sismoIdentifier for dataSource Twitter
      // 160 bits - 16 bits = 144 bits
      // we check that the first 16 bits are equal to 0x1002
      if ((userId) >> 144 != 0x1002) {
        revert InvalidSismoIdentifier(bytes32(userId), uint8(authType));
      }
    }
    if (authType == AuthType.TELEGRAM) {
      // check that the userId starts with 0x1003 -> sismoIdentifier for dataSource Telegram
      // 160 bits - 16 bits = 144 bits
      // we check that the first 16 bits are equal to 0x1003
      if ((userId) >> 144 != 0x1003) {
        revert InvalidSismoIdentifier(bytes32(userId), uint8(authType));
      }
    }
  }

  function _checkSnarkProof(HydraS3ProofData memory snarkProofData) internal {
    // low-level call to the `verifyProof` function
    // since the function only accepts arguments located in calldata
    (bool success, bytes memory result) = address(this).call(
      abi.encodeWithSelector(
        this.verifyProof.selector,
        snarkProofData.proof.a,
        snarkProofData.proof.b,
        snarkProofData.proof.c,
        snarkProofData.input
      )
    );

    if (!success) {
      revert CallToVerifyProofFailed();
    }
    bool isVerified = abi.decode(result, (bool));

    if (!isVerified) {
      revert InvalidProof();
    }
  }

  function _encodeRequestIdentifier(
    bytes16 groupId,
    bytes16 groupTimestamp,
    bytes16 appId,
    bytes16 namespace
  ) internal pure returns (uint256) {
    bytes32 groupSnapshotId = _encodeGroupSnapshotId(groupId, groupTimestamp);
    bytes32 serviceId = _encodeServiceId(appId, namespace);
    return
      uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % HydraS3Lib.SNARK_FIELD;
  }

  function _encodeAccountsTreeValue(
    bytes16 groupId,
    bytes16 groupTimestamp
  ) internal pure returns (uint256) {
    return uint256(_encodeGroupSnapshotId(groupId, groupTimestamp)) % HydraS3Lib.SNARK_FIELD;
  }

  function _encodeGroupSnapshotId(
    bytes16 groupId,
    bytes16 groupTimestamp
  ) internal pure returns (bytes32) {
    return bytes32(abi.encodePacked(groupId, groupTimestamp));
  }

  function _encodeServiceId(bytes16 appId, bytes16 namespace) internal pure returns (bytes32) {
    return bytes32(abi.encodePacked(appId, namespace));
  }

  function _encodeVaultNamespace(bytes16 appId) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(appId, bytes16(0)))) % HydraS3Lib.SNARK_FIELD;
  }
}
