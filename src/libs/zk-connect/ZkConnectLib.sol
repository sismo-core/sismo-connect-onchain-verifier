// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Context} from '@openzeppelin/contracts/utils/Context.sol';
import {ZkConnectVerifier} from 'src/ZkConnectVerifier.sol';
import {IAddressesProvider} from 'src/periphery/interfaces/IAddressesProvider.sol';
import {ZkConnectResponse, DataRequest, StatementRequest, StatementComparator, LogicalOperator } from 'src/libs/utils/Struct.sol';

contract ZkConnect is Context {
  uint256 public constant ZK_CONNECT_VERSION = 1;
  ZkConnectVerifier private zkConnectVerifier;
  bytes16 public appId;
  address public addressesProvider;

  constructor (bytes16 _appId, address _addressesProvider) {
    appId = _appId;
    addressesProvider = _addressesProvider;
    zkConnectVerifier = ZkConnectVerifier(IAddressesProvider(addressesProvider).get(string("zkConnectVerifier")));
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

  function verify(ZkConnectResponse memory zkConnectResponse, DataRequest memory dataRequest, bytes16 namespace) public {
    zkConnectVerifier.verify(appId, zkConnectResponse, dataRequest, namespace);
  }
}