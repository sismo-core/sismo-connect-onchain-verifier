// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {IZkConnectVerifier} from "./interfaces/IZkConnectVerifier.sol";
import {IBaseVerifier} from "./interfaces/IBaseVerifier.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./libs/utils/Structs.sol";

contract ZkConnectVerifier is IZkConnectVerifier, Initializable, Ownable {
  uint8 public constant IMPLEMENTATION_VERSION = 1;
  bytes32 public immutable ZK_CONNECT_VERSION = "zk-connect-v2";

  mapping(bytes32 => IBaseVerifier) public _verifiers;

  constructor(address owner) {
    initialize(owner);
  }

  function initialize(address ownerAddress) public reinitializer(IMPLEMENTATION_VERSION) {
    // if proxy did not setup owner yet or if called by constructor (for implem setup)
    if (owner() == address(0) || address(this).code.length == 0) {
      _transferOwnership(ownerAddress);
    }
  }

  function verify(
    ZkConnectResponse memory res,
    ZkConnectRequest memory req
  ) public returns (ZkConnectVerifiedResult memory) {
    (
      VerifiedAuth memory verifiedAuth,
      VerifiedClaim memory verifiedClaim,
      bytes memory verifiedSignedMessage
    ) = _verifiers[res.proofs[0].provingScheme].verify(res.appId, res.namespace, res.proofs[0]);

    VerifiedAuth[] memory verifiedAuths = new VerifiedAuth[](1);
    verifiedAuths[0] = verifiedAuth;
    VerifiedClaim[] memory verifiedClaims = new VerifiedClaim[](1);
    verifiedClaims[0] = verifiedClaim;
    bytes[] memory verifiedSignedMessages = new bytes[](1);
    verifiedSignedMessages[0] = verifiedSignedMessage;

    return
      ZkConnectVerifiedResult(
        res.appId,
        res.namespace,
        res.version,
        verifiedAuths,
        verifiedClaims,
        verifiedSignedMessages
      );
  }

  function registerVerifier(bytes32 provingScheme, address verifierAddress) public onlyOwner {
    _setVerifier(provingScheme, verifierAddress);
  }

  function getVerifier(bytes32 provingScheme) public view returns (address) {
    return address(_verifiers[provingScheme]);
  }

  function _setVerifier(bytes32 provingScheme, address verifierAddress) internal {
    _verifiers[provingScheme] = IBaseVerifier(verifierAddress);
    emit VerifierSet(provingScheme, verifierAddress);
  }

  function _checkResponseMatchesWithRequest(
    ZkConnectResponse memory res,
    ZkConnectRequest memory req
  ) internal {
    if (res.version != ZK_CONNECT_VERSION) {
      revert();
    }

    if (res.namespace != req.namespace) {
      revert();
    }

    if (res.appId != req.appId) {
      revert();
    }

    DataRequest memory dataRequest = req.content.dataRequests[0];
    ZkConnectProof memory proof = res.proofs[0];

    // if (dataRequest.claim != proof.claim) {
    //   revert();
    // }
    // if (dataRequest.auth != proof.auth) {
    //   revert();
    // }
    // if (dataRequest.signedMessage != proof.signedMessage) {
    //   revert();
    // }
  }
}
