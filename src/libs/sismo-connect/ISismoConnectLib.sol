// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISismoConnectLib {
  error SismoConnectResponseIsEmpty();
  error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
  error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);
}
