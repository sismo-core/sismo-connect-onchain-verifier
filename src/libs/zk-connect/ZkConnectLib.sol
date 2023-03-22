// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {Context} from '@openzeppelin/contracts/utils/Context.sol';
import {ZkConnectVerifier} from 'src/ZkConnectVerifier.sol';
import {IAddressesProvider} from 'src/periphery/interfaces/IAddressesProvider.sol';
import {ZkConnectResponse, DataRequest, StatementRequest, StatementComparator, LogicalOperator } from 'src/libs/utils/Struct.sol';

contract ZkConnect is Context {
  ZkConnectVerifier private _zkConnectVerifier;
  bytes16 public appId;
  address public addressesProvider;

  error ZkConnectResponseIsEmpty();
  error InvalidZkConnectVersion(bytes32 receivedVersion, bytes32 expectedVersion);
  error AppIdMismatch(bytes16 receivedAppId, bytes16 expectedAppId);
  error NamespaceMismatch(bytes16 receivedNamespace, bytes16 expectedNamespace);

  constructor (bytes16 _appId, address _addressesProvider) {
    appId = _appId;
    addressesProvider = _addressesProvider;
    _zkConnectVerifier = ZkConnectVerifier(IAddressesProvider(addressesProvider).get(string("zkConnectVerifier")));
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

  function verify(bytes memory zkConnectResponseEncoded, DataRequest memory dataRequest, bytes16 namespace) public {
    if (zkConnectResponseEncoded.length == 0) {
      revert ZkConnectResponseIsEmpty();
    }
    ZkConnectResponse memory zkConnectResponse = abi.decode(zkConnectResponseEncoded, (ZkConnectResponse));

    if (zkConnectResponse.version != _zkConnectVerifier.ZK_CONNECT_VERSION()) {
      revert InvalidZkConnectVersion(zkConnectResponse.version, _zkConnectVerifier.ZK_CONNECT_VERSION());
    }

    if (zkConnectResponse.appId != appId) {
      revert AppIdMismatch(zkConnectResponse.appId, appId);
    }

    if (zkConnectResponse.namespace != namespace) {
      revert NamespaceMismatch(zkConnectResponse.namespace, namespace);
    }


    _zkConnectVerifier.verify(appId, zkConnectResponse, dataRequest, namespace);
  }
}