// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";
import {SignatureBuilder} from "./SignatureBuilder.sol";
import {ISismoConnectLib} from "../../interfaces/ISismoConnectLib.sol";

contract RequestBuilder {
  // default value for namespace
  bytes16 public constant DEFAULT_NAMESPACE = bytes16(keccak256("main"));
  // default value for a signature request
  SignatureRequest DEFAULT_SIGNATURE_REQUEST =
    SignatureRequest({
      message: "MESSAGE_SELECTED_BY_USER",
      isSelectableByUser: false,
      extraData: ""
    });

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    ClaimRequest memory claim,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest memory auth,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    AuthRequest memory auth,
    ClaimRequest memory claim,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    AuthRequest memory auth,
    SignatureRequest memory signature,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    AuthRequest memory auth,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](1);
    auths[0] = auth;
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    ClaimRequest memory claim,
    SignatureRequest memory signature,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    ClaimRequest memory claim,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    ClaimRequest[] memory claims = new ClaimRequest[](1);
    claims[0] = claim;
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  // build with arrays for auths and claims

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    ClaimRequest[] memory claims,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    bytes16 appId,
    bytes16 namespace
  ) external view returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: namespace
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    ClaimRequest[] memory claims,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    SignatureRequest memory signature,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    AuthRequest[] memory auths,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    ClaimRequest[] memory claims = new ClaimRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    ClaimRequest[] memory claims,
    SignatureRequest memory signature,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: signature,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }

  function build(
    ClaimRequest[] memory claims,
    bytes16 appId
  ) external view returns (SismoConnectRequest memory) {
    AuthRequest[] memory auths = new AuthRequest[](0);
    return (
      SismoConnectRequest({
        auths: auths,
        claims: claims,
        signature: DEFAULT_SIGNATURE_REQUEST,
        appId: appId,
        vault: ISismoConnectLib(msg.sender).vault(),
        namespace: DEFAULT_NAMESPACE
      })
    );
  }
}
