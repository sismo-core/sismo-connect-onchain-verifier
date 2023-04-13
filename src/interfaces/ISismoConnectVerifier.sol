// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

interface ISismoConnectVerifier {
  event VerifierSet(bytes32, address);

  error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
  error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);
  error VersionMismatch(bytes32 requestVersion, bytes32 responseVersion);
  error SignatureMessageMismatch(bytes requestMessageSignature, bytes responseMessageSignature);

  function verify(
    SismoConnectResponse memory response,
    SismoConnectRequest memory request
  ) external returns (SismoConnectVerifiedResult memory);

  function SISMO_CONNECT_VERSION() external view returns (bytes32);
}
