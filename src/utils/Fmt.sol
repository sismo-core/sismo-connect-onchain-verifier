// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Structs.sol";
import "forge-std/console.sol";

library fmt {
  function printAuthRequest(AuthRequest memory auth, string memory indication) external view {
    console.log(indication);
    console.log("authType", uint8(auth.authType));
    console.log("isAnon", auth.isAnon);
    console.log("userId", auth.userId);
    console.log("isOptional", auth.isOptional);
    console.log("isSelectableByUser", auth.isSelectableByUser);
    console.log("extraData");
    console.logBytes(auth.extraData);
  }

  function printAuth(Auth memory auth, string memory indication) external view {
    console.log(indication);
    console.log("authType", uint8(auth.authType));
    console.log("isAnon", auth.isAnon);
    console.log("userId", auth.userId);
    console.log("isSelectableByuser", auth.isSelectableByUser);
    console.log("extraData");
    console.logBytes(auth.extraData);
  }
}
