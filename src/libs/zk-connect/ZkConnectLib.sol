// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Context} from '@openzeppelin/contracts/utils/Context.sol';
import {ZkConnectVerifier} from 'src/ZkConnectVerifier.sol';

contract ZkConnectLib is Context {
  uint256 public constant ZK_CONNECT_VERSION = 1;
  ZkConnectVerifier private zkConnectVerifier;

  constructor (bytes16 appId) {
    zkConnectVerifier = new ZkConnectVerifier(appId);
  }
}