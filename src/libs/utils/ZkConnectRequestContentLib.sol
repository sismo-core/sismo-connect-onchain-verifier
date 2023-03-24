// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

library ZkConnectRequestContentLib {
    function build(DataRequest[] memory dataRequests, LogicalOperator operator)
        public
        returns (ZkConnectRequestContent memory)
    {
        uint256 logicalOperatorsLength;
        if (dataRequests.length == 1) {
            logicalOperatorsLength = 1;
        } else {
            logicalOperatorsLength = dataRequests.length - 1;
        }

        LogicalOperator[] memory operators = new LogicalOperator[](logicalOperatorsLength);
        for (uint256 i = 0; i < operators.length; i++) {
            operators[i] = operator;
        }
        return ZkConnectRequestContent({dataRequests: dataRequests, operators: operators});
    }

    function build(DataRequest memory dataRequest) public returns (ZkConnectRequestContent memory) {
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = dataRequest;
        return build({dataRequests: dataRequests, operator: LogicalOperator.AND});
    }
}
