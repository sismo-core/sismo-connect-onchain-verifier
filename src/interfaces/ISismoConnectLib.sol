// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISismoConnectLib {
  function appId() external view returns (bytes16);

  function isImpersonationMode() external view returns (bool);
}
