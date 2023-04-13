// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IBaseVerifier} from "../interfaces/IBaseVerifier.sol";
import {IHydraS2Verifier} from "./IHydraS2Verifier.sol";
import {HydraS2Verifier as HydraS2SnarkVerifier} from "@sismo-core/hydra-s2/HydraS2Verifier.sol";
import {ICommitmentMapperRegistry} from "../periphery/interfaces/ICommitmentMapperRegistry.sol";
import {IAvailableRootsRegistry} from "../periphery/interfaces/IAvailableRootsRegistry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {HydraS2ProofData, HydraS2Lib, HydraS2ProofInput} from "./HydraS2Lib.sol";
import {Auth, ClaimType, AuthType, Claim, SismoConnectProof, VerifiedAuth, VerifiedClaim} from "src/libs/utils/Structs.sol";

contract HydraS2Verifier is IHydraS2Verifier, IBaseVerifier, HydraS2SnarkVerifier, Initializable {
  using HydraS2Lib for HydraS2ProofData;
  using HydraS2Lib for Auth;
  using HydraS2Lib for Claim;

  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable HYDRA_S2_VERSION = "hydra-s2.1";
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
    bytes memory signedMessage,
    SismoConnectProof memory sismoConnectProof
  ) external view override returns (VerifiedAuth memory, VerifiedClaim memory) {
    // Verify the sismoConnectProof version corresponds to the current verifier.
    if (sismoConnectProof.provingScheme != HYDRA_S2_VERSION) {
      revert InvalidVersion(sismoConnectProof.provingScheme);
    }

    // Decode the snark proof from the sismoConnectProof
    // This snark proof is specify to this proving scheme
    HydraS2ProofData memory snarkProof = abi.decode(
      sismoConnectProof.proofData,
      (HydraS2ProofData)
    );
    HydraS2ProofInput memory snarkInput = snarkProof._input();

    // We only support one Auth and one Claim in the hydra-s2 proving scheme
    // We revert if there is more than one Auth or Claim in the sismoConnectProof
    if (sismoConnectProof.auths.length > 1 || sismoConnectProof.claims.length > 1) {
      revert OnlyOneAuthAndOneClaimIsSupported();
    }

    // Verify Claim, Auth and SignedMessage validity by checking corresponding
    // snarkProof public input
    VerifiedAuth memory verifiedAuth;
    VerifiedClaim memory verifiedClaim;
    if (sismoConnectProof.auths.length == 1) {
      // Get the Auth from the sismoConnectProof
      // We only support one Auth in the hydra-s2 proving scheme
      Auth memory auth = sismoConnectProof.auths[0];
      verifiedAuth = _verifyAuthValidity(snarkInput, sismoConnectProof.proofData, auth, appId);
    }
    if (sismoConnectProof.claims.length == 1) {
      // Get the Claim from the sismoConnectProof
      // We only support one Claim in the hydra-s2 proving scheme
      Claim memory claim = sismoConnectProof.claims[0];
      verifiedClaim = _verifyClaimValidity(
        snarkInput,
        sismoConnectProof.proofData,
        claim,
        appId,
        namespace
      );
    }

    _validateSignedMessageInput(snarkInput, signedMessage);

    // Check the snarkProof is valid
    _checkSnarkProof(snarkProof);

    return (verifiedAuth, verifiedClaim);
  }

  function _verifyClaimValidity(
    HydraS2ProofInput memory input,
    bytes memory proofData,
    Claim memory claim,
    bytes16 appId,
    bytes16 namespace
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
    HydraS2ProofInput memory input,
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
    HydraS2ProofInput memory input,
    bytes memory signedMessage
  ) private pure {
    // don't check extraData if signedMessage is empty
    if (signedMessage.length == 0) {
      return;
    }
    if (input.extraData != uint256(keccak256(signedMessage)) % HydraS2Lib.SNARK_FIELD) {
      revert InvalidExtraData(
        input.extraData,
        uint256(keccak256(signedMessage)) % HydraS2Lib.SNARK_FIELD
      );
    }
  }

  function _checkSnarkProof(HydraS2ProofData memory snarkProof) internal view {
    if (
      !verifyProof(snarkProof.proof.a, snarkProof.proof.b, snarkProof.proof.c, snarkProof.input)
    ) {
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
      uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % HydraS2Lib.SNARK_FIELD;
  }

  function _encodeAccountsTreeValue(
    bytes16 groupId,
    bytes16 groupTimestamp
  ) internal pure returns (uint256) {
    return uint256(_encodeGroupSnapshotId(groupId, groupTimestamp)) % HydraS2Lib.SNARK_FIELD;
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
    return uint256(keccak256(abi.encodePacked(appId, bytes16(0)))) % HydraS2Lib.SNARK_FIELD;
  }
}
