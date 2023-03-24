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

    function build(DataRequest[] memory dataRequests) public returns (ZkConnectRequestContent memory) {
        return build({dataRequests: dataRequests, operator: LogicalOperator.AND});
    }

    function build(DataRequest memory dataRequest, LogicalOperator operator)
        public
        returns (ZkConnectRequestContent memory)
    {
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = dataRequest;
        return build({dataRequests: dataRequests, operator: operator});
    }

    function build(DataRequest memory dataRequest) public returns (ZkConnectRequestContent memory) {
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = dataRequest;
        return build({dataRequests: dataRequests, operator: LogicalOperator.AND});
    }

    function build(Claim memory claimRequest, Auth memory authRequest, bytes memory messageSignatureRequest)
        public
        returns (ZkConnectRequestContent memory)
    {
        DataRequest memory dataRequest = DataRequest({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
        return build(dataRequest);
    }

    function build(Claim memory claimRequest, Auth memory authRequest)
        public
        returns (ZkConnectRequestContent memory)
    {
        return build({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(Claim memory claimRequest, bytes memory messageSignatureRequest)
        public
        returns (ZkConnectRequestContent memory)
    {
        Auth memory authRequest;
        return build({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(Auth memory authRequest, bytes memory messageSignatureRequest)
        public
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest;
        return build({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(Claim memory claimRequest) public returns (ZkConnectRequestContent memory) {
        Auth memory authRequest;
        return build({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(Auth memory authRequest) public returns (ZkConnectRequestContent memory) {
        Claim memory claimRequest;
        return build({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(bytes memory messageSignatureRequest) public returns (ZkConnectRequestContent memory) {
        Claim memory claimRequest;
        Auth memory authRequest;
        return build({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }
}
