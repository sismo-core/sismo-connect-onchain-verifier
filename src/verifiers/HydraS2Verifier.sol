// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "../interfaces/IBaseVerifier.sol";
import {HydraS2Verifier as HydraS2SnarkVerifier} from "@sismo-core/hydra-s2/HydraS2Verifier.sol";
import {ICommitmentMapperRegistry} from "../periphery/interfaces/ICommitmentMapperRegistry.sol";
import {IAvailableRootsRegistry} from "../periphery/interfaces/IAvailableRootsRegistry.sol";
import "../libs/utils/Struct.sol";
import "../libs/utils/Constants.sol";
import "forge-std/console.sol";

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
// statementComparator;
// vaultIdentifier;
// vaultNamespace;
// sourceVerificationEnabled;
// destinationVerificationEnabled;

contract HydraS2Verifier is IBaseVerifier, HydraS2SnarkVerifier {
    bytes32 immutable HYDRA_S2_VERSION = "hydra-s2.1";
    // Registry storing the Commitment Mapper EdDSA Public key
    ICommitmentMapperRegistry immutable COMMITMENT_MAPPER_REGISTRY;
    // Registry storing the Registry Tree Roots of the Attester's available ClaimData
    IAvailableRootsRegistry immutable AVAILABLE_ROOTS_REGISTRY;

    error InvalidProof();

    error ProofContainsTooManyStatements(uint256 numberOfStatements);
    error InvalidVersion(bytes32 version);
    error RegistryRootMismatch(uint256 inputRoot);
    error DestinationMismatch(address destinationFromProof, address expectedDestination);
    error CommitmentMapperPubKeyMismatch(uint256 expectedX, uint256 expectedY, uint256 inputX, uint256 inputY);

    error StatementComparatorMismatch(uint256 statementComparatorFromProof, StatementComparator expectedStatementComparator);
    error MismatchRequestIdentifier(uint256 requestIdentifierFromProof, uint256 expectedRequestIdentifier);
    error InvalidExtraData();
    error InvalidRequestedValue();
    error DestinationVerificationNeedsToBeEnabled();
    error SourceVerificationNeedsToBeEnabled();
    error AccountsTreeValueMismatch(uint256 accountsTreeValueFromProof, uint256 expectedAccountsTreeValue);
    error AppIdMismatch(bytes16 appIdFromProof, bytes16 expectedAppId);

    constructor(address commitmentMapperRegistry, address availableRootsRegistry) {
        COMMITMENT_MAPPER_REGISTRY = ICommitmentMapperRegistry(commitmentMapperRegistry);
        AVAILABLE_ROOTS_REGISTRY = IAvailableRootsRegistry(availableRootsRegistry);
    }

    function verify(bytes16 appId, bytes16 namespace, ZkConnectProof memory proof, address destination)
        public
        view
        override
        returns (uint256 vaultId, VerifiedStatement memory)
    {
        if (proof.provingScheme != HYDRA_S2_VERSION) {
            revert InvalidVersion(proof.provingScheme);
        }

        Statement memory statement = proof.statement;

        HydraS2SnarkProof memory snarkProof = abi.decode(proof.proofData, (HydraS2SnarkProof));

        _checkPublicInputs(appId, namespace, statement, snarkProof.inputs);
        _checkSnarkProof(snarkProof);

        VerifiedStatement memory verifiedStatement = VerifiedStatement({
            groupId: statement.groupId,
            groupTimestamp: statement.groupTimestamp,
            value: statement.value,
            comparator: statement.comparator,
            provingScheme: proof.provingScheme,
            proofId: snarkProof.inputs[6],
            extraData: statement.extraData
        });

        return (snarkProof.inputs[10], verifiedStatement);
    }

    function _checkPublicInputs(bytes16 appId, bytes16 namespace, Statement memory statement, uint256[14] memory inputs)
        internal
        view
    {
        address destinationIdentifier = address(uint160(inputs[0]));
        uint256 extraData = inputs[1];
        uint256 commitmentMapperPubKeyX = inputs[2];
        uint256 commitmentMapperPubKeyY = inputs[3];
        uint256 registryTreeRoot = inputs[4];
        uint256 requestIdentifier = inputs[5];
        uint256 proofIdentifier = inputs[6];
        uint256 statementValue = inputs[7];
        uint256 accountsTreeValue = inputs[8];
        uint256 statementComparator = inputs[9];
        uint256 vaultIdentifier = inputs[10];
        uint256 vaultNamespace = inputs[11];
        bool sourceVerificationEnabled = inputs[12] == 1;
        bool destinationVerificationEnabled = inputs[13] == 1;


        // statementComparator
        bool isStatementComparatorFromProofEqualToOne = statementComparator == 1;
        bool isStatementComparatorFromStatementEqualToEQ = statement.comparator == StatementComparator.EQ;
        if (isStatementComparatorFromProofEqualToOne != isStatementComparatorFromStatementEqualToEQ) {
            revert StatementComparatorMismatch(statementComparator, statement.comparator);
        }
        // statementValue
        if (statementValue != statement.value) {
            revert InvalidRequestedValue();
        }
        // requestIdentifier
        uint256 expectedRequestIdentifier = _encodeRequestIdentifier(appId, statement.groupId, statement.groupTimestamp, namespace);
        if (requestIdentifier != expectedRequestIdentifier) {
            revert MismatchRequestIdentifier(requestIdentifier, expectedRequestIdentifier);
        }
        // commitmentMapperPubKey
        uint256[2] memory commitmentMapperPubKey = COMMITMENT_MAPPER_REGISTRY.getEdDSAPubKey();
        if (commitmentMapperPubKeyX != commitmentMapperPubKey[0] || commitmentMapperPubKeyY != commitmentMapperPubKey[1]) {
            revert CommitmentMapperPubKeyMismatch(
                commitmentMapperPubKey[0], commitmentMapperPubKey[1], commitmentMapperPubKeyX, commitmentMapperPubKeyY
            );
        }
        // destinationVerificationEnabled
        // if (destinationVerificationEnabled == false) {
        //     revert DestinationVerificationNeedsToBeEnabled();
        // }
        // destinationIdentifier
        // if (destinationIdentifier != destination) {
        //     revert DestinationMismatch(destinationIdentifier, destination);
        // }
        // sourceVerificationEnabled
        if (sourceVerificationEnabled == false) {
            revert SourceVerificationNeedsToBeEnabled();
        }
        // isRootAvailable
        if (!AVAILABLE_ROOTS_REGISTRY.isRootAvailable(registryTreeRoot)) {
            revert RegistryRootMismatch(registryTreeRoot);
        }
        // accountsTreeValue
        uint256 groupSnapshotId = _encodeAccountsTreeValue(statement.groupId, statement.groupTimestamp);
        if (accountsTreeValue != groupSnapshotId) {
            revert AccountsTreeValueMismatch(accountsTreeValue, groupSnapshotId);
        }
        // proofIdentifier
        bytes16 appIdFromProof = bytes16(uint128(vaultNamespace));
        if (appIdFromProof != bytes16(appId)) {
            revert AppIdMismatch(appIdFromProof, appId);
        }
    }

    function _checkSnarkProof(HydraS2SnarkProof memory snarkProof) internal view {
        if (!verifyProof(snarkProof.a, snarkProof.b, snarkProof.c, snarkProof.inputs)) {
            revert InvalidProof();
        }
    }

    function _encodeRequestIdentifier(bytes16 appId, bytes16 groupId, bytes16 groupTimestamp, bytes16 namespace) private pure returns (uint256) {
        bytes32 groupSnapshotId = bytes32(abi.encodePacked(groupId, groupTimestamp));
        bytes32 serviceId = bytes32(abi.encodePacked(appId, namespace));
        return uint256(keccak256(abi.encodePacked(serviceId, groupSnapshotId))) % SNARK_FIELD;
    }

    function _encodeAccountsTreeValue(bytes16 groupId, bytes16 groupTimestamp) private pure returns (uint256) {
        return uint256(bytes32(abi.encodePacked(groupId, groupTimestamp))) % SNARK_FIELD;
    }
}
