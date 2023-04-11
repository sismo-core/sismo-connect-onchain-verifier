// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

interface ISismoConnectVerifier {
  event VerifierSet(bytes32, address);

  function verify(
    SismoConnectResponse memory response,
    SismoConnectRequest memory request
  ) external returns (SismoConnectVerifiedResult memory);

  function SISMO_CONNECT_VERSION() external view returns (bytes32);
}
