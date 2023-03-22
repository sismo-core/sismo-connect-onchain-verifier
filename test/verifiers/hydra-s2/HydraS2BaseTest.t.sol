// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {BaseTest} from "test/BaseTest.t.sol";
import "src/verifiers/HydraS2Verifier.sol";
import "./proofs/HydraS2Proofs.sol";
import "test/mocks/CommitmentMapperRegistryMock.sol";
import "test/mocks/AvailableRootsRegistryMock.sol";

contract HydraS2BaseTest is BaseTest {
    HydraS2Proofs immutable hydraS2Proofs = new HydraS2Proofs();
    HydraS2Verifier hydraS2Verifier;
    ICommitmentMapperRegistry commitmentMapperRegistry;
    IAvailableRootsRegistry availableRootsRegistry;

    function setUp() public virtual override {
        super.setUp();

        commitmentMapperRegistry = new CommitmentMapperRegistryMock();
        availableRootsRegistry = new AvailableRootsRegistryMock();

        hydraS2Verifier = new HydraS2Verifier(address(commitmentMapperRegistry), address(availableRootsRegistry));

        zkConnectVerifier.setVerifier("hydra-s2.1", address(hydraS2Verifier));

        commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(hydraS2Proofs.getEdDSAPubKey());
        availableRootsRegistry.registerRoot(hydraS2Proofs.getRoot());
    }

    function createDataRequest(bytes16 groupId, bytes16 groupTimestamp, bytes16 namespace) 
        public 
        pure 
        returns (DataRequest memory) 
    {
       StatementRequest[] memory statementRequests = new StatementRequest[](1);
        statementRequests[0] = StatementRequest({
            groupId: groupId,
            groupTimestamp: groupTimestamp,
            requestedValue: 0,
            comparator: StatementComparator.GTE,
            provingScheme: "hydra-s2.1",
            extraData: ""
        });
        DataRequest memory dataRequest =
            DataRequest({statementRequests: statementRequests, operator: LogicalOperator.AND});

        return (dataRequest);
    }
}
