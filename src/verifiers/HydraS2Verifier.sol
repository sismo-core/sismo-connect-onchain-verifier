// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IBaseVerifier} from "../interfaces/IBaseVerifier.sol";
import {HydraS2Verifier as HydraS2SnarkVerifier} from "@sismo-core/hydra-s2/HydraS2Verifier.sol";
import "../libs/Struct.sol";

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
    bytes32 immutable HYDRA_S2_VERSION = "hydra-s2-v1";

    error InvalidProof();

    error ProofContainsTooManyStatements(uint256 numberOfStatements);
    error InvalidVersion(bytes32 version);

    error InvalidExtraData();
    error InvalidRequestedValue();

    function verify(bytes16 appId, bytes16 namespace, ZkConnectProof memory proof)
        public
        override
        returns (uint256 vaultId, VerifiedStatement[] memory)
    {
        // HydraS2 Proving scheme only accept 1 statement per proof
        if (proof.statements.length > 1) {
            revert ProofContainsTooManyStatements(proof.statements.length);
        }
        if (proof.provingScheme != HYDRA_S2_VERSION) {
            revert InvalidVersion(proof.provingScheme);
        }

        Statement memory statement = proof.statements[0];

        HydraS2SnarkProof memory snarkProof = abi.decode(proof.proofData, (HydraS2SnarkProof));

        _checkPublicInputs(appId, namespace, statement, snarkProof.inputs);
        _checkSnarkProof(snarkProof);

        VerifiedStatement[] memory verifiedStatements = new VerifiedStatement[](1);
        verifiedStatements[0] = VerifiedStatement({
            groupId: statement.groupId,
            groupTimestamp: statement.groupTimestamp,
            requestedValue: statement.requestedValue,
            value: statement.value,
            comparator: statement.comparator,
            provingScheme: proof.provingScheme,
            proofId: snarkProof.inputs[6],
            extraData: statement.extraData
        });

        return (snarkProof.inputs[10], verifiedStatements);
    }

    function _checkPublicInputs(bytes16 appId, bytes16 namespace, Statement memory statement, uint256[14] memory inputs)
        internal
        pure
    {
        if (uint256(keccak256(statement.extraData)) != inputs[1]) {
            revert InvalidExtraData();
        }
        if (statement.requestedValue != inputs[7]) {
            revert InvalidRequestedValue();
        }
    }

    function _checkSnarkProof(HydraS2SnarkProof memory snarkProof) internal view {
        if (!verifyProof(snarkProof.a, snarkProof.b, snarkProof.c, snarkProof.inputs)) {
            revert InvalidProof();
        }
    }
}
