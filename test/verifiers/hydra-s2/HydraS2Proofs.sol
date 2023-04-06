// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/libs/utils/Structs.sol";

contract HydraS2Proofs {
  // default value for Claim
  bytes16 public constant DEFAULT_CLAIM_GROUP_TIMESTAMP = bytes16("latest");
  uint256 public constant DEFAULT_CLAIM_VALUE = 1;
  bytes16 public constant DEFAULT_CLAIM_GROUP_ID = "";
  ClaimType public constant DEFAULT_CLAIM_TYPE = ClaimType.GTE;
  bytes public constant DEFAULT_CLAIM_EXTRA_DATA = "";

  // default values for Auth
  bool public constant DEFAULT_AUTH_ANON_MODE = false;
  uint256 public constant DEFAULT_AUTH_USER_ID = 0;
  bytes public constant DEFAULT_AUTH_EXTRA_DATA = "";

  // default values for MessageSignature
  bytes public constant DEFAULT_MESSAGE_SIGNATURE_REQUEST = "MESSAGE_SELECTED_BY_USER";

  // default value for namespace
  bytes16 public constant DEFAULT_NAMESPACE = bytes16(keccak256("main"));

  function getEdDSAPubKey() public pure returns (uint256[2] memory) {
    return [
      0x7f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb9,
      0x20706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa
    ];
  }

  function getRoot() public pure returns (uint256) {
    return 0x1d4a72bd1c1e4f9ab68c3c4c55afd3e582685a18b9ec09fc96136619d2513fe8;
  }

  // simple sismoConnect with 1 statement
  function getSismoConnectResponse1() public view returns (SismoConnectResponse memory) {
    Claim memory claim = Claim({
      groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
      groupTimestamp: bytes16("latest"),
      value: 1,
      claimType: ClaimType.GTE,
      extraData: ""
    });

    // empty auth
    Auth memory auth = this.GET_EMPTY_AUTH();

    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = SismoConnectProof({
      claim: claim,
      auth: auth,
      signedMessage: abi.encode(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"027e2ac77cccdd6a170377c53d01745477d8e220eea25899bd551a6d93a0287928d68511985e87a2c00e406a9689bfee26975214f087b257c2cfbb0d8422081b177b788f52df265b9a455441d16f1ba2775cbf46e065d956e21abda4170bb23223d275e7e1a049db15f41c5398f1e4cc41e89d4175134bdcc0695142a33c90ca2dd94b68dcb64b88911aa13f5a78e0aa0de1eb6d5b0e911960370d080108961b0df136e1229ccf8d38290fc8287999d2b9fbf0339c45abaacd489b8ff081773710f1270f26800a2b1e86ef3ed8eab23acaef9ec8115865a552f29791e6209060203b8deb2e7d4847bead3fcf406c83aef1a9b25c87676cc73e610f672f1e0c79000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa1900027a626c79673bcd47d69cf371248a6ba78feee2ec32c5e83b681af8433904f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc00000000000000000000000000000000000000000000000000000000000000000c5e3eb3996b56ed6e60c6c7823f4fa3e972a882bef34f6f35ed769bb60c35f90000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      SismoConnectResponse({
        appId: 0x11b1de449c6c4adb0b5775b3868b28b3,
        namespace: bytes16(keccak256("main")),
        version: bytes32("zk-connect-v2"),
        proofs: proofs
      });
  }

  // simple sismoConnect with only auth
  function getSismoConnectResponse2() public view returns (SismoConnectResponse memory) {
    Claim memory claim = this.GET_EMPTY_CLAIM();

    // empty auth
    Auth memory auth = Auth({authType: AuthType.ANON, isAnon: false, userId: 0, extraData: ""});

    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = SismoConnectProof({
      claim: claim,
      auth: auth,
      signedMessage: abi.encode(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"0b529e93acffaf27bf2505c9dcd7fae7656f7bb29175d24e90c23f2e6ea64317050237db8bf9ed4ad987e70425a90ebbd40f23f317ee656d00f0dab7ae2f6de10b1ef11c91c6bed2202e91c3a7b1e897bd8a057e32b3580d19bd6414f112c6152da3dae4046a38b19713a18e028ae19241657a8bfc9dc8a3a3307211ad5a90d106f98ecd507dba20059147cf8beedb10dc07e4f5c4891d3635502a93756571f323835b3792f3c8770a168887674f9bb317aadb39e2ebdfcf634a5aed256d298924226d0bc3c107267a4360568524fbd3ecfa74165ba250be3c0d359f8291628e1eed8bac192f1d602edcb580f27e2462cbbd1f7ae691a4539a71d81c4489d828000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d07f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c5e3eb3996b56ed6e60c6c7823f4fa3e972a882bef34f6f35ed769bb60c35f90000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      SismoConnectResponse({
        appId: 0x11b1de449c6c4adb0b5775b3868b28b3,
        namespace: bytes16(keccak256("main")),
        version: bytes32("zk-connect-v2"),
        proofs: proofs
      });
  }

  function GET_EMPTY_CLAIM() external pure returns (Claim memory) {
    return  Claim({
        claimType: ClaimType.EMPTY,
        groupId: DEFAULT_CLAIM_GROUP_ID,
        groupTimestamp: DEFAULT_CLAIM_GROUP_TIMESTAMP,
        value: DEFAULT_CLAIM_VALUE,
        extraData: DEFAULT_CLAIM_EXTRA_DATA
      });
  }

  function GET_EMPTY_AUTH() public pure returns (Auth memory) {
    return
      Auth({
        authType: AuthType.EMPTY,
        isAnon: DEFAULT_AUTH_ANON_MODE,
        userId: DEFAULT_AUTH_USER_ID,
        extraData: DEFAULT_AUTH_EXTRA_DATA
      });
  }
}
