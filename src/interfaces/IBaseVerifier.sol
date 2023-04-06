// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import {SismoConnectProof, VerifiedAuth, VerifiedClaim} from "src/libs/utils/Structs.sol";

interface IBaseVerifier {
  function verify(
    bytes16 appId,
    bytes16 namespace,
    bytes memory signedMessage,
    SismoConnectProof memory sismoConnectProof
  ) external view returns (VerifiedAuth memory, VerifiedClaim memory);
}
