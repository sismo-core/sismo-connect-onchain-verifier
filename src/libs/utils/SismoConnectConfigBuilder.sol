// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";

library SismoConnectConfigBuilder {
  function build(bytes16 appId) external pure returns (SismoConnectConfig memory) {
    return SismoConnectConfig({appId: appId, vault: VaultConfigBuilder.build()});
  }

  function build(
    bytes16 appId,
    bool isImpersonationMode
  ) external pure returns (SismoConnectConfig memory) {
    return SismoConnectConfig({appId: appId, vault: VaultConfigBuilder.build(isImpersonationMode)});
  }
}

library VaultConfigBuilder {
  function build() external pure returns (VaultConfig memory) {
    return VaultConfig({isImpersonationMode: false});
  }

  function build(bool isImpersonationMode) external pure returns (VaultConfig memory) {
    return VaultConfig({isImpersonationMode: isImpersonationMode});
  }
}
