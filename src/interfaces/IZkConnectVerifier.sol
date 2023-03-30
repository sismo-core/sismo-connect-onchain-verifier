// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

interface IZkConnectVerifier {
  function verify(ZkConnectResponse memory zkConnectResponse, ZkConnectRequestContent memory zkConnectRequestContent)
        external
        returns (ZkConnectVerifiedResult memory);

  function ZK_CONNECT_VERSION() external view returns (bytes32);
}