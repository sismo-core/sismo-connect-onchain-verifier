// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";
import "./StatementRequestLib.sol";

library DataRequestLib {
    function build(StatementRequest[] memory statementRequests, LogicalOperator operator)
        public
        returns (DataRequest memory dataRequest)
    {
        return DataRequest({statementRequests: statementRequests, operator: operator});
    }

    function build(StatementRequest memory statementRequest) public returns (DataRequest memory dataRequest) {
        StatementRequest[] memory statementRequests = new StatementRequest[](1);
        statementRequests[0] = statementRequest;
        return build({statementRequests: statementRequests, operator: LogicalOperator.AND});
    }

    function build(bytes16 groupId) public returns (DataRequest memory dataRequest) {
        StatementRequest[] memory statementRequests = new StatementRequest[](1);
        statementRequests[0] = StatementRequestLib.build({groupId: groupId});
        return build({statementRequests: statementRequests, operator: LogicalOperator.AND});
    }

    function build(bytes16 groupId, bytes16 groupTimestamp) public returns (DataRequest memory dataRequest) {
        return build({groupId: groupId, groupTimestamp: groupTimestamp});
    }

    function build(bytes16 groupId, uint256 requestedValue) public returns (DataRequest memory dataRequest) {
        return build({groupId: groupId, requestedValue: requestedValue});
    }

    function build(bytes16 groupId, bytes memory extraData) public returns (DataRequest memory dataRequest) {
        return build({groupId: groupId, extraData: extraData});
    }
}
