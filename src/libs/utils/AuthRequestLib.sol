// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

library AuthRequestLib {
    function build(AuthType authType, bool anonMode, uint256 userId, bytes memory extraData)
        public
        pure
        returns (Auth memory)
    {
        return Auth({authType: authType, anonMode: anonMode, userId: userId, extraData: extraData, isValid: true});
    }

    function build(AuthType authType) public pure returns (Auth memory) {
        bool anonMode = false;
        uint256 userId = 0;
        bytes memory extraData = "";
        return build(authType, anonMode, userId, extraData);
    }

    function build(AuthType authType, bool anonMode) public pure returns (Auth memory) {
        uint256 userId = 0;
        bytes memory extraData = "";
        return build(authType, anonMode, userId, extraData);
    }

    function build(AuthType authType, uint256 userId) public pure returns (Auth memory) {
        bool anonMode = false;
        bytes memory extraData = "";
        return build(authType, anonMode, userId, extraData);
    }

    function build(AuthType authType, bytes memory extraData) public pure returns (Auth memory) {
        bool anonMode = false;
        uint256 userId = 0;
        return build(authType, anonMode, userId, extraData);
    }

    function build(AuthType authType, bool anonMode, uint256 userId) public pure returns (Auth memory) {
        bytes memory extraData = "";
        return build(authType, anonMode, userId, extraData);
    }

    function build(AuthType authType, bool anonMode, bytes memory extraData) public pure returns (Auth memory) {
        uint256 userId = 0;
        return build(authType, anonMode, userId, extraData);
    }

    function build(AuthType authType, uint256 userId, bytes memory extraData) public pure returns (Auth memory) {
        bool anonMode = false;
        return build(authType, anonMode, userId, extraData);
    }
}
