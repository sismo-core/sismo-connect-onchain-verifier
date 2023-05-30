// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Vault} from "../libs/utils/Structs.sol";

interface ISismoConnectLib {
  function appId() external view returns (bytes16);

  function vault() external view returns (Vault);
}
