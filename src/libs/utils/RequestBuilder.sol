// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";
import {SignatureBuilder} from "src/libs/utils/SignatureBuilder.sol";

library RequestBuilder {
  // default value for namespace
  bytes16 public constant DEFAULT_NAMESPACE = bytes16(keccak256("main"));

  function _GET_EMPTY_SIGNATURE_REQUEST() internal pure returns (SignatureRequest memory) {
    return SignatureBuilder.buildEmpty();
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest memory claim,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest memory auth,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  // buildRequest with arrays for auths and claims
  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    bytes16 appId,
    bytes16 namespace
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: namespace,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: signature
      })
    );
  }

  function buildRequest(
    AuthRequest[] memory auths,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }

  function buildRequest(
    ClaimRequest[] memory claims,
    bytes16 appId
  ) external pure returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        appId: appId,
        namespace: DEFAULT_NAMESPACE,
        auths: auths,
        claims: claims,
        signature: _GET_EMPTY_SIGNATURE_REQUEST()
      })
    );
  }
}
