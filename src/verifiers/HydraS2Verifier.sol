// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "../interfaces/IBaseVerifier.sol";
import {HydraS2Verifier as HydraS2SnarkVerifier} from "@sismo-core/hydra-s2/HydraS2Verifier.sol";
import {ICommitmentMapperRegistry} from "../periphery/interfaces/ICommitmentMapperRegistry.sol";
import {IAvailableRootsRegistry} from "../periphery/interfaces/IAvailableRootsRegistry.sol";
import "../libs/Struct.sol";
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
    error DestinationMismatch(address expectedDestination, address inputDestination);
    error CommitmentMapperPubKeyMismatch(uint256 expectedX, uint256 expectedY, uint256 inputX, uint256 inputY);

    error InvalidExtraData();
    error InvalidRequestedValue();

    constructor(address commitmentMapperRegistry, address availableRootsRegistry) {
        COMMITMENT_MAPPER_REGISTRY = ICommitmentMapperRegistry(commitmentMapperRegistry);
        AVAILABLE_ROOTS_REGISTRY = IAvailableRootsRegistry(availableRootsRegistry);
    }

    function verify(bytes16 appId, bytes16 namespace, ZkConnectProof memory proof)
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
        // if (uint256(keccak256(statement.extraData)) != inputs[1]) {
        //     revert InvalidExtraData();
        // }
        uint256[2] memory commitmentMapperPubKey = COMMITMENT_MAPPER_REGISTRY.getEdDSAPubKey();
        if (inputs[2] != commitmentMapperPubKey[0] || inputs[3] != commitmentMapperPubKey[1]) {
            revert CommitmentMapperPubKeyMismatch(
                commitmentMapperPubKey[0], commitmentMapperPubKey[1], inputs[2], inputs[3]
            );
        }
        if (!AVAILABLE_ROOTS_REGISTRY.isRootAvailable(inputs[4])) {
            revert RegistryRootMismatch(inputs[4]);
        }
        if (statement.value != inputs[7]) {
            revert InvalidRequestedValue();
        }
    }

    function _checkSnarkProof(HydraS2SnarkProof memory snarkProof) internal view {
        if (!verifyProof(snarkProof.a, snarkProof.b, snarkProof.c, snarkProof.inputs)) {
            revert InvalidProof();
        }
    }
}
