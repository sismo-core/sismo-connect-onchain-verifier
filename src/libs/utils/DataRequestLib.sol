// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";
import "./ClaimRequestLib.sol";

library ZkConnectRequestContentLib {
    function build(DataRequest[] memory dataRequests, LogicalOperator operator)
        public
        returns (ZkConnectRequestContent memory)
    {
        LogicalOperator[] memory operators = new LogicalOperator[](dataRequests.length - 1);
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

    function build(bytes16 groupId) public returns (ZkConnectRequestContent memory) {
        DataRequest[] memory dataRequests = new DataRequest[](1);
        Claim memory claim = ClaimRequestLib.build(groupId);
        Auth memory auth;
        dataRequests[0] = DataRequest({claimRequest: claim, authRequest: auth, messageSignatureRequest: "" });
        return build({dataRequests: dataRequests, operator: LogicalOperator.AND});
    }

    function build(bytes16 groupId, bytes16 groupTimestamp) public returns (ZkConnectRequestContent memory) {
        return build({groupId: groupId, groupTimestamp: groupTimestamp});
    }

    function build(bytes16 groupId, uint256 requestedValue) public returns (ZkConnectRequestContent memory) {
        return build({groupId: groupId, requestedValue: requestedValue});
    }

    function build(bytes16 groupId, bytes memory extraData) public returns (ZkConnectRequestContent memory) {
        return build({groupId: groupId, extraData: extraData});
    }
}
