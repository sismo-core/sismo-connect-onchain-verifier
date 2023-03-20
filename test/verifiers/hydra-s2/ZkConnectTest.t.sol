// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import {HydraS2BaseTest} from "./HydraS2BaseTest.t.sol";
import "src/libs/Struct.sol";

contract ZkConnectTest is HydraS2BaseTest {
    function testZkConnect() public {
        bytes16 appId = 0x112a692a2005259c25f6094161007967;
        bytes16 namespace = "main";

        StatementRequest[] memory statementRequests = new StatementRequest[](1);
        statementRequests[0] = StatementRequest({
            groupId: 0x112a692a2005259c25f6094161007967,
            groupTimestamp: 0x112a692a2005259c25f6094161007967,
            requestedValue: 0,
            comparator: StatementComparator.GTE,
            provingScheme: "hydra-s2.1",
            extraData: ""
        });
        DataRequest memory dataRequest =
            DataRequest({statementRequests: statementRequests, operator: LogicalOperator.AND});

        zkConnectVerifier.verify(appId, hydraS2Proofs.getZkConnectResponse1(), dataRequest, namespace);
    }
}
