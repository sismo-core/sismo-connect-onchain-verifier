// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {BaseTest} from "test/BaseTest.t.sol";
import "src/verifiers/HydraS3Verifier.sol";
import "./HydraS3Proofs.sol";
import {CommitmentMapperRegistryMock, ICommitmentMapperRegistry} from "test/mocks/CommitmentMapperRegistryMock.sol";
import {AvailableRootsRegistryMock} from "test/mocks/AvailableRootsRegistryMock.sol";

contract HydraS3BaseTest is BaseTest {
  HydraS3Proofs immutable hydraS3Proofs = new HydraS3Proofs();
  HydraS3Verifier hydraS3Verifier;
  ICommitmentMapperRegistry commitmentMapperRegistry;
  AvailableRootsRegistryMock availableRootsRegistry;

  function setUp() public virtual override {
    super.setUp();

    commitmentMapperRegistry = new CommitmentMapperRegistryMock();
    availableRootsRegistry = new AvailableRootsRegistryMock();

    hydraS3Verifier = new HydraS3Verifier(
      address(commitmentMapperRegistry),
      address(availableRootsRegistry)
    );

    vm.startPrank(owner);
    sismoConnectVerifier.registerVerifier(
      hydraS3Verifier.HYDRA_S3_VERSION(),
      address(hydraS3Verifier)
    );
    vm.stopPrank();

    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(hydraS3Proofs.getEdDSAPubKey());
    availableRootsRegistry.registerRoot(hydraS3Proofs.getRoot());
  }
}
