// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

library ClaimRequestLib {
    ///////////////////////////
    // groupId + groupTimestamp + value + claimType + extraData
    //////////////////////////
    function build(bytes16 groupId, bytes16 groupTimestamp, uint256 value, ClaimType claimType, bytes memory extraData)
        public
        pure
        returns (Claim memory)
    {
        return Claim({
            groupId: groupId,
            groupTimestamp: groupTimestamp,
            value: value,
            claimType: claimType,
            extraData: extraData,
            isValid: true
        });
    }
    ///////////////////////////
    // groupId
    ///////////////////////////

    function build(bytes16 groupId) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        uint256 value = 1;
        ClaimType claimType = ClaimType.GTE;
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, bytes16 groupTimestamp) public pure returns (Claim memory) {
        uint256 value = 1;
        ClaimType claimType = ClaimType.GTE;
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, uint256 value) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        ClaimType claimType = ClaimType.GTE;
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, ClaimType claimType) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        uint256 value = 1;
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, bytes memory extraData) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        uint256 value = 1;
        ClaimType claimType = ClaimType.GTE;
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + groupTimestamp
    //////////////////////////
    function build(bytes16 groupId, bytes16 groupTimestamp, uint256 value) public pure returns (Claim memory) {
        ClaimType claimType = ClaimType.GTE;
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, bytes16 groupTimestamp, ClaimType claimType) public pure returns (Claim memory) {
        uint256 value = 1;
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, bytes16 groupTimestamp, bytes memory extraData)
        public
        pure
        returns (Claim memory)
    {
        uint256 value = 1;
        ClaimType claimType = ClaimType.GTE;
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + value
    //////////////////////////
    function build(bytes16 groupId, uint256 value, ClaimType claimType) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, uint256 value, bytes memory extraData) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        ClaimType claimType = ClaimType.GTE;
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + claimType
    //////////////////////////
    function build(bytes16 groupId, ClaimType claimType, bytes memory extraData) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        uint256 value = 1;
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + extraData (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + groupTimestamp + value
    //////////////////////////
    function build(bytes16 groupId, bytes16 groupTimestamp, uint256 value, ClaimType claimType)
        public
        pure
        returns (Claim memory)
    {
        bytes memory extraData = "";
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    function build(bytes16 groupId, bytes16 groupTimestamp, uint256 value, bytes memory extraData)
        public
        pure
        returns (Claim memory)
    {
        ClaimType claimType = ClaimType.GTE;
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + groupTimestamp + claimType
    //////////////////////////
    function build(bytes16 groupId, bytes16 groupTimestamp, ClaimType claimType, bytes memory extraData)
        public
        pure
        returns (Claim memory)
    {
        uint256 value = 1;
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + groupTimestamp + extraData (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + value + claimType
    //////////////////////////
    function build(bytes16 groupId, uint256 value, ClaimType claimType, bytes memory extraData)
        public
        pure
        returns (Claim memory)
    {
        bytes16 groupTimestamp = bytes16("latest");
        return build(groupId, groupTimestamp, value, claimType, extraData);
    }

    ///////////////////////////
    // groupId + value + extraData (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + claimType + extraData (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + groupTimestamp + value + claimType (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + groupTimestamp + value + extraData (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + groupTimestamp + claimType + extraData (all cases handled)
    //////////////////////////

    ///////////////////////////
    // groupId + value + claimType + extraData (all cases handled)
    //////////////////////////
}
