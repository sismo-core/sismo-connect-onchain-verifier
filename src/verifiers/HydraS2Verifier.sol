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

    error InvalidExtraData();
    error InvalidRequestedValue();

    function verify(bytes16 appId, bytes16 namespace, VerifiableStatement memory statement)
        public
        override
        returns (uint256 vaultId, uint256 proofId)
    {
        HydraS2SnarkProof memory snarkProof = abi.decode(statement.proof, (HydraS2SnarkProof));

        _checkPublicInputs(appId, namespace, statement, snarkProof.inputs);
        _checkSnarkProof(snarkProof);

        return (snarkProof.inputs[10], snarkProof.inputs[6]);
    }

    function _checkPublicInputs(
        bytes16 appId,
        bytes16 namespace,
        VerifiableStatement memory statement,
        uint256[14] memory inputs
    ) internal pure {
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
