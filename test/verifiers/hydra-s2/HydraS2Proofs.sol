// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/libs/utils/Structs.sol";
import "src/libs/utils/ClaimRequestLib.sol";

contract HydraS2Proofs {
  function getEdDSAPubKey() public pure returns (uint256[2] memory) {
    return [
      0x7f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb9,
      0x20706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa
    ];
  }

  function getRoot() public pure returns (uint256) {
    return 0x1d4a72bd1c1e4f9ab68c3c4c55afd3e582685a18b9ec09fc96136619d2513fe8;
  }

  // simple zkConnect with 1 statement
  function getZkConnectResponse1() public view returns (ZkConnectResponse memory) {
    Claim memory claim = Claim({
      groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
      groupTimestamp: bytes16("latest"),
      value: 1,
      claimType: ClaimType.GTE,
      extraData: ""
    });

    // empty auth
    Auth memory auth;

    ZkConnectProof[] memory proofs = new ZkConnectProof[](1);
    proofs[0] = ZkConnectProof({
      claim: claim,
      auth: auth,
      signedMessage: abi.encodePacked(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"14da2fd6df57ab7f7424e31ee3f3704be885e66e4576ce60eeff619b2c98348318f706db46f798114581927d45192c832fd2b65bb6c1140c85c26970a7230a8a002a37fbca95eca1e8d6c37fdf72754ba04b9d29d5c3d6254af60847cf6a4090222b7b949d6f6fba5a66720dc13cfafb94c1eb3a35df788fbff1fd32fd09684c16ecb1a2aaf985fe7785cdb0424871442800c6e49f0d7593d34720ab7acdf3292fecfdfc723ed00535a7fc25ef6aed7bee60965b537be3c596b200a24fa2d47b1dabbf310f766c876b4b44beb2045791ffdafabd60b29176bf7e01bec21f1feb1c24a035d18827d2a037cc33ff0b1032d8a6d5c13af3d338839a98534ed85d43000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa2db629f18dc904ef403dd497303d02e8f0b4059786899373d734f3c6389442ec0edcebd3d30d0a9e5ba1fbaae8057165de46b61ddc5e81b1701dbf79995d77e51f853dbff160e80ee19ed2e3ae534c228873736d841ecec2339564c28a31db2d0000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000015fb9d7ca9f692b09201b5277a41f295ce6530786b4ce23051ef72c53252097300000000000000000000000000000000f68985adfc209fafebfb1a956913e7fa00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    console.log("abi.encodePacked(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE)");
    console.logBytes(abi.encodePacked(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE));

    return
      ZkConnectResponse({
        appId: 0xf68985adfc209fafebfb1a956913e7fa,
        namespace: bytes16(keccak256("main")),
        version: bytes32("zk-connect-v2"),
        proofs: proofs
      });
  }

  // simple zkConnect with only auth
  function getZkConnectResponse2() public pure returns (ZkConnectResponse memory) {
    Claim memory claim;

    // empty auth
    Auth memory auth = Auth({authType: AuthType.ANON, anonMode: false, userId: 0, extraData: ""});

    ZkConnectProof[] memory proofs = new ZkConnectProof[](1);
    proofs[0] = ZkConnectProof({
      claim: claim,
      auth: auth,
      signedMessage: "",
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"279c51e95b9d599d763242a65a6c4b52d2c2963c74ba45c935a6388f51772a8e1ec281aea3c994db606ea01199ad61a5be923a711eb915e232e7f0cff71bb6ac10b6db0a34adae5195498276b6dfb3944d14776b7be693f315ab11e9d5f99b711c2a3057a794be9add241e6ea4be75627da615f669c215a1849f1550e291b06116198092bf0f2f2aebbc353b7a412952f2f0a8b8763ef1d3dcb60906cd930a380c1d289e20241b75cd35d1f5aa39f97aea4cf4f31a6162dcb91c1284d72850f221bc0e15269474ed91666d1d7dc9193f9e0d78c5d85692955029b3e6e14583011eef7c0dacc72376c81f0432fcce8d7a0ab8c9c700eacc4e0be755f4df51441c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa2db629f18dc904ef403dd497303d02e8f0b4059786899373d734f3c6389442ec0edcebd3d30d0a9e5ba1fbaae8057165de46b61ddc5e81b1701dbf79995d77e51f853dbff160e80ee19ed2e3ae534c228873736d841ecec2339564c28a31db2d0000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000015fb9d7ca9f692b09201b5277a41f295ce6530786b4ce23051ef72c53252097300000000000000000000000000000000f68985adfc209fafebfb1a956913e7fa00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      ZkConnectResponse({
        appId: 0xf68985adfc209fafebfb1a956913e7fa,
        namespace: bytes16(keccak256("main")),
        version: bytes32("zk-connect-v2"),
        proofs: proofs
      });
  }
}
