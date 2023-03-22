// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

library StatementLib {
    function build(
        bytes16 groupId,
        bytes16 groupTimestamp,
        uint256 value,
        StatementComparator comparator,
        bytes memory extraData
    ) public returns (Statement memory) {
        return Statement({
            groupId: groupId,
            groupTimestamp: bytes16("latest"),
            value: 1,
            comparator: StatementComparator.GTE,
            extraData: extraData
        });
    }

    function build(bytes16 groupId) public returns (Statement memory) {
        return build({
            groupId: groupId,
            groupTimestamp: bytes16("latest"),
            value: 1,
            comparator: StatementComparator.GTE,
            extraData: ""
        });
    }

    function build(bytes16 groupId, bytes16 groupTimestamp) public returns (Statement memory) {
        return build({groupId: groupId, groupTimestamp: groupTimestamp});
    }

    function build(bytes16 groupId, uint256 value) public returns (Statement memory) {
        return build({groupId: groupId, value: value});
    }

    function build(bytes16 groupId, bytes memory extraData) public returns (Statement memory) {
        return build({groupId: groupId, extraData: extraData});
    }
}
