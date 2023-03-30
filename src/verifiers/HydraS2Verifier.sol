// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IBaseVerifier} from "../interfaces/IBaseVerifier.sol";
import {HydraS2Verifier as HydraS2SnarkVerifier} from "@sismo-core/hydra-s2/HydraS2Verifier.sol";
import {ICommitmentMapperRegistry} from "../periphery/interfaces/ICommitmentMapperRegistry.sol";
import {IAvailableRootsRegistry} from "../periphery/interfaces/IAvailableRootsRegistry.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../libs/utils/Structs.sol";
import "../libs/utils/Constants.sol";

struct HydraS2SnarkProof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    uint256[14] inputs;
}
// destinationIdentifier;
// extraData;
// commitmentMapperPubKey.X;
// commitmentMapperPubKey.Y;
// registryTreeRoot;
// requestIdentifier;
// proofIdentifier;
// statementValue;
// accountsTreeValue;
// claimType;
// vaultIdentifier;
// vaultNamespace;
// sourceVerificationEnabled;
// destinationVerificationEnabled;

contract HydraS2Verifier is IBaseVerifier, HydraS2SnarkVerifier, Initializable {
    uint8 public constant IMPLEMENTATION_VERSION = 1;
    bytes32 public immutable HYDRA_S2_VERSION = "hydra-s2.1";
    // Registry storing the Commitment Mapper EdDSA Public key
    ICommitmentMapperRegistry public immutable COMMITMENT_MAPPER_REGISTRY;
    // Registry storing the Registry Tree Roots of the Attester's available ClaimData
    IAvailableRootsRegistry public immutable AVAILABLE_ROOTS_REGISTRY;

    error InvalidProof();
    error AnonModeIsNotYetSupported();

    error InvalidVersion(bytes32 version);
    error RegistryRootMismatch(uint256 inputRoot);
    error DestinationMismatch(address destinationFromProof, address expectedDestination);
    error CommitmentMapperPubKeyMismatch(uint256 expectedX, uint256 expectedY, uint256 inputX, uint256 inputY);

    error ClaimTypeMismatch(uint256 claimTypeFromProof, ClaimType expectedClaimType);
    error MismatchRequestIdentifier(uint256 requestIdentifierFromProof, uint256 expectedRequestIdentifier);
    error InvalidExtraData(bytes32 extraDataFromProof, bytes32 expectedExtraData);
    error InvalidClaimValue();
    error DestinationVerificationNeedsToBeEnabled();
    error SourceVerificationNeedsToBeEnabled();
    error AccountsTreeValueMismatch(uint256 accountsTreeValueFromProof, uint256 expectedAccountsTreeValue);
    error AppIdMismatch(bytes16 appIdFromProof, bytes16 expectedAppId);

    constructor(address commitmentMapperRegistry, address availableRootsRegistry) {
        COMMITMENT_MAPPER_REGISTRY = ICommitmentMapperRegistry(commitmentMapperRegistry);
        AVAILABLE_ROOTS_REGISTRY = IAvailableRootsRegistry(availableRootsRegistry);
        initialize();
    }

    function initialize() public reinitializer(IMPLEMENTATION_VERSION) {}

    function verifyClaim(bytes16 appId, bytes16 namespace, ZkConnectProof memory zkConnectProof)
        public
        view
        override
        returns (VerifiedClaim memory)
    {
        if (zkConnectProof.provingScheme != HYDRA_S2_VERSION) {
            revert InvalidVersion(zkConnectProof.provingScheme);
        }

        Claim memory claim = zkConnectProof.claim;

        HydraS2SnarkProof memory snarkProof = abi.decode(zkConnectProof.proofData, (HydraS2SnarkProof));

        _checkPublicInputs(appId, namespace, claim, snarkProof.inputs, zkConnectProof);
        _checkSnarkProof(snarkProof);

        VerifiedClaim memory verifiedClaim = VerifiedClaim({
            groupId: claim.groupId,
            groupTimestamp: claim.groupTimestamp,
            value: claim.value,
            claimType: claim.claimType,
            proofId: snarkProof.inputs[6],
            extraData: claim.extraData
        });

        return verifiedClaim;
    }

    function verifyAuthProof(bytes16 appId, ZkConnectProof memory zkConnectProof)
        public
        view
        returns (VerifiedAuth memory)
    {
        if (zkConnectProof.provingScheme != HYDRA_S2_VERSION) {
            revert InvalidVersion(zkConnectProof.provingScheme);
        }

        HydraS2SnarkProof memory snarkProof = abi.decode(zkConnectProof.proofData, (HydraS2SnarkProof));

        uint256 extraData = snarkProof.inputs[1];
        bytes16 appIdFromProof = bytes16(uint128(snarkProof.inputs[11]));
        if (appIdFromProof != appId) {
            revert AppIdMismatch(appIdFromProof, appId);
        }
        if (extraData != uint256(keccak256(zkConnectProof.signedMessage))) {
            revert InvalidExtraData(bytes32(extraData), keccak256(zkConnectProof.signedMessage));
        }

        Auth memory auth = zkConnectProof.auth;


        uint256 returnedUserId = snarkProof.inputs[10]; // vaultIdentifier by default
        bool destinationVerificationEnabled = snarkProof.inputs[13] == 1; // destinationVerificationEnabled
        uint256 destinationIdentifier = uint256(snarkProof.inputs[0]); // destinationIdentifier

        // if the authType is not ANON (i.e. if it's not a vault authentication)
        // we check that the proof of ownership of the destinationIdentifier is made in the circuit
        // and we return the destinationIdentifier as the userId (instead of the vaultIdentifier by default)
        if (auth.authType != AuthType.ANON) {
            if (auth.anonMode == true) {
                revert AnonModeIsNotYetSupported();
            }
            if (destinationVerificationEnabled == false) {
                revert DestinationVerificationNeedsToBeEnabled();
            }
            returnedUserId = destinationIdentifier;
        }

        _checkSnarkProof(snarkProof);

        return VerifiedAuth({
            authType: auth.authType,
            anonMode: auth.anonMode,
            userId: returnedUserId,
            extraData: auth.extraData,
            proofId: snarkProof.inputs[6]
        });
    }

    function _checkPublicInputs(
        bytes16 appId,
        bytes16 namespace,
        Claim memory claim,
        uint256[14] memory inputs,
        ZkConnectProof memory zkConnectProof
    ) internal view {
        //address destinationIdentifier = address(uint160(inputs[0]));
        uint256 extraData = inputs[1];
        uint256 commitmentMapperPubKeyX = inputs[2];
        uint256 commitmentMapperPubKeyY = inputs[3];
        uint256 registryTreeRoot = inputs[4];
        uint256 requestIdentifier = inputs[5];
        // proofIdentifier inputs[6]
        uint256 claimValue = inputs[7]; // statementValue in circuits
        uint256 accountsTreeValue = inputs[8];
        uint256 claimType = inputs[9]; // statementComparator in circuits
        // vaultIdentifier inputs[10]
        uint256 vaultNamespace = inputs[11];
        bool sourceVerificationEnabled = inputs[12] == 1;
        // destinationVerificationEnabled inputs[13]

        // claimType
        bool isClaimTypeFromProofEqualToOne = claimType == 1;
        bool isClaimTypeFromClaimEqualToEQ = claim.claimType == ClaimType.EQ;
        if (isClaimTypeFromProofEqualToOne != isClaimTypeFromClaimEqualToEQ) {
            revert ClaimTypeMismatch(claimType, claim.claimType);
        }
        // claimValue
        if (claimValue != claim.value) {
            revert InvalidClaimValue();
        }
        // requestIdentifier
        uint256 expectedRequestIdentifier =
            _encodeRequestIdentifier(appId, claim.groupId, claim.groupTimestamp, namespace);
        if (requestIdentifier != expectedRequestIdentifier) {
            revert MismatchRequestIdentifier(requestIdentifier, expectedRequestIdentifier);
        }
        // commitmentMapperPubKey
        uint256[2] memory commitmentMapperPubKey = COMMITMENT_MAPPER_REGISTRY.getEdDSAPubKey();
        if (
            commitmentMapperPubKeyX != commitmentMapperPubKey[0] || commitmentMapperPubKeyY != commitmentMapperPubKey[1]
        ) {
            revert CommitmentMapperPubKeyMismatch(
                commitmentMapperPubKey[0], commitmentMapperPubKey[1], commitmentMapperPubKeyX, commitmentMapperPubKeyY
            );
        }
        // sourceVerificationEnabled
        if (sourceVerificationEnabled == false) {
            revert SourceVerificationNeedsToBeEnabled();
        }
        // isRootAvailable
        if (!AVAILABLE_ROOTS_REGISTRY.isRootAvailable(registryTreeRoot)) {
            revert RegistryRootMismatch(registryTreeRoot);
        }
        // accountsTreeValue
        uint256 groupSnapshotId = _encodeAccountsTreeValue(claim.groupId, claim.groupTimestamp);
        if (accountsTreeValue != groupSnapshotId) {
            revert AccountsTreeValueMismatch(accountsTreeValue, groupSnapshotId);
        }
        // proofIdentifier
        bytes16 appIdFromProof = bytes16(uint128(vaultNamespace));
        if (appIdFromProof != bytes16(appId)) {
            revert AppIdMismatch(appIdFromProof, appId);
        }
        // extraData
        if (extraData != uint256(keccak256(zkConnectProof.signedMessage))) {
            revert InvalidExtraData(bytes32(extraData), keccak256(zkConnectProof.signedMessage));
        }
    }

    function _checkSnarkProof(HydraS2SnarkProof memory snarkProof) internal view {
        if (!verifyProof(snarkProof.a, snarkProof.b, snarkProof.c, snarkProof.inputs)) {
            revert InvalidProof();
        }
    }

    function _encodeRequestIdentifier(bytes16 appId, bytes16 groupId, bytes16 groupTimestamp, bytes16 namespace)
        private
        pure
        returns (uint256)
    {
        bytes32 groupSnapshotId = bytes32(abi.encodePacked(groupId, groupTimestamp));
        bytes32 serviceId = bytes32(abi.encodePacked(appId, namespace));
        return uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % SNARK_FIELD;
    }

    function _encodeAccountsTreeValue(bytes16 groupId, bytes16 groupTimestamp) private pure returns (uint256) {
        return uint256(bytes32(abi.encodePacked(groupId, groupTimestamp))) % SNARK_FIELD;
    }
}
