// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

library ClaimRequestLib {
    function build(
        bytes16 groupId,
        bytes16 groupTimestamp,
        uint256 value,
        ClaimType claimType,
        bytes memory extraData
    ) public pure returns (Claim memory) {
        return Claim({
            groupId: groupId,
            groupTimestamp: groupTimestamp,
            value: value,
            claimType: claimType,
            extraData: extraData,
            isValid: true
        });
    }

    function build(bytes16 groupId) public pure returns (Claim memory) {
        bytes16 groupTimestamp = bytes16("latest");
        uint256 value = 1;
        ClaimType comparator = ClaimType.GTE;
        bytes memory extraData = "";
        return build(
            groupId,
            groupTimestamp,
            value,
            comparator,
            extraData
        );
    }

    function build(bytes16 groupId, bytes16 groupTimestamp) public returns (Claim memory) {
        return build({groupId: groupId, groupTimestamp: groupTimestamp});
    }

    function build(bytes16 groupId, uint256 requestedValue) public returns (Claim memory) {
        return build({groupId: groupId, requestedValue: requestedValue});
    }

    function build(bytes16 groupId, bytes memory extraData) public returns (Claim memory) {
        return build({groupId: groupId, extraData: extraData});
    }
}
