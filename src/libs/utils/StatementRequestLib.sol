// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

library StatementRequestLib {
    function build(
        bytes16 groupId,
        bytes16 groupTimestamp,
        uint256 requestedValue,
        StatementComparator comparator,
        bytes memory extraData
    ) public returns (StatementRequest memory) {
        return StatementRequest({
            groupId: groupId,
            groupTimestamp: bytes16("latest"),
            requestedValue: 1,
            comparator: StatementComparator.GTE,
            extraData: extraData
        });
    }

    function build(bytes16 groupId) public returns (StatementRequest memory) {
        return build({
            groupId: groupId,
            groupTimestamp: bytes16("latest"),
            requestedValue: 1,
            comparator: StatementComparator.GTE,
            extraData: ""
        });
    }

    function build(bytes16 groupId, bytes16 groupTimestamp) public returns (StatementRequest memory) {
        return build({groupId: groupId, groupTimestamp: groupTimestamp});
    }

    function build(bytes16 groupId, uint256 requestedValue) public returns (StatementRequest memory) {
        return build({groupId: groupId, requestedValue: requestedValue});
    }

    function build(bytes16 groupId, bytes memory extraData) public returns (StatementRequest memory) {
        return build({groupId: groupId, extraData: extraData});
    }
}
