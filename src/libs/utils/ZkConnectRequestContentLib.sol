// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Struct.sol";

import {AuthRequestLib} from "src/libs/utils/AuthRequestLib.sol";
import {ClaimRequestLib} from "src/libs/utils/ClaimRequestLib.sol";

library ZkConnectRequestContentLib {
    function build(DataRequest[] memory dataRequests, LogicalOperator operator)
        public
        pure
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

    function build(DataRequest[] memory dataRequests) public pure returns (ZkConnectRequestContent memory) {
        return build({dataRequests: dataRequests, operator: LogicalOperator.AND});
    }

    function build(DataRequest memory dataRequest, LogicalOperator operator)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = dataRequest;
        return build({dataRequests: dataRequests, operator: operator});
    }

    function build(DataRequest memory dataRequest) public pure returns (ZkConnectRequestContent memory) {
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = dataRequest;
        return build({dataRequests: dataRequests, operator: LogicalOperator.AND});
    }

    function build(Claim memory claimRequest, Auth memory authRequest, bytes memory messageSignatureRequest)
        public
        pure
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
        pure
        returns (ZkConnectRequestContent memory)
    {
        return build({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(Claim memory claimRequest, bytes memory messageSignatureRequest)
        public
        pure
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
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest;
        return build({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(Claim memory claimRequest) public pure returns (ZkConnectRequestContent memory) {
        Auth memory authRequest;
        return build({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(Auth memory authRequest) public pure returns (ZkConnectRequestContent memory) {
        Claim memory claimRequest;
        return build({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(bytes memory messageSignatureRequest) public pure returns (ZkConnectRequestContent memory) {
        Claim memory claimRequest;
        Auth memory authRequest;
        return build({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    // Build a ZkConnectRequestContent with a single AuthRequest
    function buildAuthOnly(AuthType authType, bool anonMode, uint256 userId, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Auth memory authRequest =
            AuthRequestLib.build({authType: authType, anonMode: anonMode, userId: userId, extraData: extraData});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType, bool anonMode, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Auth memory authRequest = AuthRequestLib.build({authType: authType, anonMode: anonMode, extraData: extraData});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType, bool anonMode, uint256 userId)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Auth memory authRequest = AuthRequestLib.build({authType: authType, anonMode: anonMode, userId: userId});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType, uint256 userId, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Auth memory authRequest = AuthRequestLib.build({authType: authType, userId: userId, extraData: extraData});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Auth memory authRequest = AuthRequestLib.build({authType: authType, extraData: extraData});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType, uint256 userId) public pure returns (ZkConnectRequestContent memory) {
        Auth memory authRequest = AuthRequestLib.build({authType: authType, userId: userId});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType, bool anonMode) public pure returns (ZkConnectRequestContent memory) {
        Auth memory authRequest = AuthRequestLib.build({authType: authType, anonMode: anonMode});
        return build(authRequest);
    }

    function buildAuthOnly(AuthType authType) public pure returns (ZkConnectRequestContent memory) {
        Auth memory authRequest = AuthRequestLib.build({authType: authType});
        return build(authRequest);
    }

    // Build a ZkConnectRequestContent with a single ClaimRequest

    function buildClaimOnly(bytes16 groupId) public pure returns (ZkConnectRequestContent memory) {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes16 groupTimestamp)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId, groupTimestamp: groupTimestamp});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, uint256 value) public pure returns (ZkConnectRequestContent memory) {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId, value: value});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, ClaimType claimType)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId, claimType: claimType});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId, extraData: extraData});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes16 groupTimestamp, uint256 value)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest =
            ClaimRequestLib.build({groupId: groupId, groupTimestamp: groupTimestamp, value: value});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes16 groupTimestamp, ClaimType claimType)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest =
            ClaimRequestLib.build({groupId: groupId, groupTimestamp: groupTimestamp, claimType: claimType});
        return build(claimRequest);
    }

    function bbuildClaimOnlyild(bytes16 groupId, bytes16 groupTimestamp, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest =
            ClaimRequestLib.build({groupId: groupId, groupTimestamp: groupTimestamp, extraData: extraData});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, uint256 value, ClaimType claimType)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId, value: value, claimType: claimType});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, uint256 value, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({groupId: groupId, value: value, extraData: extraData});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, ClaimType claimType, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest =
            ClaimRequestLib.build({groupId: groupId, claimType: claimType, extraData: extraData});
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes16 groupTimestamp, uint256 value, ClaimType claimType)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({
            groupId: groupId,
            groupTimestamp: groupTimestamp,
            value: value,
            claimType: claimType
        });
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes16 groupTimestamp, uint256 value, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({
            groupId: groupId,
            groupTimestamp: groupTimestamp,
            value: value,
            extraData: extraData
        });
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, bytes16 groupTimestamp, ClaimType claimType, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest = ClaimRequestLib.build({
            groupId: groupId,
            groupTimestamp: groupTimestamp,
            claimType: claimType,
            extraData: extraData
        });
        return build(claimRequest);
    }

    function buildClaimOnly(bytes16 groupId, uint256 value, ClaimType claimType, bytes memory extraData)
        public
        pure
        returns (ZkConnectRequestContent memory)
    {
        Claim memory claimRequest =
            ClaimRequestLib.build({groupId: groupId, value: value, claimType: claimType, extraData: extraData});
        return build(claimRequest);
    }
}
