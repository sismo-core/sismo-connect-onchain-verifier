// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/libs/utils/Structs.sol";
import {RequestBuilder} from "src/libs/utils/RequestBuilder.sol";
import {ICommitmentMapperRegistry} from "test/mocks/CommitmentMapperRegistryMock.sol";

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

  function getEdDSAPubKeyDevBeta() public pure returns (uint256[2] memory) {
    return [
      0x2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f0256, 
      0x30423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74
    ];
  }

  function getRoot() public pure returns (uint256) {
    return 0x1d4a72bd1c1e4f9ab68c3c4c55afd3e582685a18b9ec09fc96136619d2513fe8;
  }

  // simple sismoConnect with 1 claim
  function getSismoConnectResponse1(ICommitmentMapperRegistry commitmentMapperRegistry) external returns (SismoConnectResponse memory) {
    // update EdDSA public key for proof made in dev.beta environment
    uint256[2] memory devBetaCommitmentMapperPubKey = [
      0x2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f0256, 
      0x30423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74
    ];
    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(devBetaCommitmentMapperPubKey);
    
    Claim memory claim = Claim({
      groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
      groupTimestamp: bytes16("latest"),
      value: 1,
      isSelectableByUser: true,
      claimType: ClaimType.GTE,
      extraData: ""
    });

    Auth[] memory auths = new Auth[](0);
    Claim[] memory claims = new Claim[](1);
    claims[0] = claim;

    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = SismoConnectProof({
      auths: auths,
      claims: claims,
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"0f487f6a8182ed2628c890aef1bff29773ea6320437c42e9a3bc58b63c809caa0e22943a9b1bbafc49624d510168c897c1976582fb75cbaf235f76252d97dc942ca3623b27e6b82bea0ca60828803e429930afcad4a9d738f697469a0b71444821f61ff6a0694408c7fc35552af3afd5d419140ae803988271b9b2ac8642e6632a8b6e48fab58cda8500b87b84e11047858635b8931d288cd91e03b42a0471032fb4c6a8d8b47ede9617bf4fd5a22eb46dc7a48bb0c1e1b5f931c5c17fbde8792aa7911b50d49fb6c9ddb1ff862b02ebefcee9ccaff99037da3d1dfe1776665f05698d69bf496ed5f1fddbf0fdf01e7512938cd7d6f1231c260d20d5252badb1000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74093e6683b2c6feac4f9ceb45edbae9a9e36c111856ec08cc0e00ae218ddc8cd304f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc0000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      SismoConnectResponse({
        appId: 0x11b1de449c6c4adb0b5775b3868b28b3,
        namespace: bytes16(keccak256("main")),
        version: bytes32("sismo-connect-v1"),
        signedMessage: abi.encode(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
        proofs: proofs
      });
  }

  // simple sismoConnect with 2 claims
  function getSismoConnectResponse2(ICommitmentMapperRegistry commitmentMapperRegistry) external returns (SismoConnectResponse memory) {
    // update EdDSA public key for proof made in dev.beta environment
    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(getEdDSAPubKeyDevBeta());

    Claim memory claim = Claim({
      groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
      groupTimestamp: bytes16("latest"),
      value: 1,
      isSelectableByUser: true,
      claimType: ClaimType.GTE,
      extraData: ""
    });

    Claim memory claimTwo = Claim({
      groupId: 0x02d241fdb9d4330c564ffc0a36af05f6,
      groupTimestamp: bytes16("latest"),
      value: 1,
      isSelectableByUser: true,
      claimType: ClaimType.GTE,
      extraData: ""
    });

    Auth[] memory auths = new Auth[](0);
    Claim[] memory claims = new Claim[](1);
    Claim[] memory claimsTwo = new Claim[](1);
    claims[0] = claim;
    claimsTwo[0] = claimTwo;

    SismoConnectProof[] memory proofs = new SismoConnectProof[](2);
    proofs[0] = SismoConnectProof({
      auths: auths,
      claims: claims,
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"0f487f6a8182ed2628c890aef1bff29773ea6320437c42e9a3bc58b63c809caa0e22943a9b1bbafc49624d510168c897c1976582fb75cbaf235f76252d97dc942ca3623b27e6b82bea0ca60828803e429930afcad4a9d738f697469a0b71444821f61ff6a0694408c7fc35552af3afd5d419140ae803988271b9b2ac8642e6632a8b6e48fab58cda8500b87b84e11047858635b8931d288cd91e03b42a0471032fb4c6a8d8b47ede9617bf4fd5a22eb46dc7a48bb0c1e1b5f931c5c17fbde8792aa7911b50d49fb6c9ddb1ff862b02ebefcee9ccaff99037da3d1dfe1776665f05698d69bf496ed5f1fddbf0fdf01e7512938cd7d6f1231c260d20d5252badb1000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74093e6683b2c6feac4f9ceb45edbae9a9e36c111856ec08cc0e00ae218ddc8cd304f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc0000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });
    proofs[1] = SismoConnectProof({
      auths: auths,
      claims: claimsTwo,
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"19735ce4cb40ccf1f7c39671f8f23aced3a16245122c89020efc5ac75c1dd80312917860861c0d92944b26558d0bba4918d4ded53dc03aff098c6e2042d61a0a0152128611339940b19943a76d2646e6d558e6856b6e8041baf5f28119c7bcc6060459294e408ced6f9c67b4e2c1fa8fae199853f7fe6816a6cb4932a5d1248418f64c33f48bc90e6c19fedfc1acdfb202c636c9d09e49566164da7ee3197fab1997b822a695da2c2ad3804f21401ce66438d3c534696c6f69ab749eff8c0aeb08cf7c754b114f2faaeb18c5018da85e736804d5981a82b16eec03be21aab79824983dd0f8091c2e2d7b7d211cb3eff407dd7c42a83a286930afe2ca41f8a33a000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74093e6683b2c6feac4f9ceb45edbae9a9e36c111856ec08cc0e00ae218ddc8cd30f1d1d7e673892c9109c8b536253aa86d1d9dbd317ee37e71f22391e3a9fa5b3138cc656a4ed3352a074f68b57d684b33506d71ef40054fa928402c4897d14b8000000000000000000000000000000000000000000000000000000000000000102d241fdb9d4330c564ffc0a36af05f66c6174657374000000000000000000000000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      SismoConnectResponse({
        appId: 0x11b1de449c6c4adb0b5775b3868b28b3,
        namespace: bytes16(keccak256("main")),
        version: bytes32("sismo-connect-v1"),
        signedMessage: abi.encode(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
        proofs: proofs
      });
  }

  // simple sismoConnect with only auth
  function getSismoConnectResponse3(ICommitmentMapperRegistry commitmentMapperRegistry) external returns (SismoConnectResponse memory) {
    // update EdDSA public key for proof made in dev.beta environment
    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(getEdDSAPubKeyDevBeta());

    Auth memory auth = Auth({authType: AuthType.VAULT, isAnon: false, isSelectableByUser: true, userId: 0, extraData: ""});
    Auth[] memory auths = new Auth[](1);
    auths[0] = auth;
    Claim[] memory claims = new Claim[](0);

    SismoConnectProof[] memory proofs = new SismoConnectProof[](1);
    proofs[0] = SismoConnectProof({
      claims: claims,
      auths: auths,
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"28b5eaa3df4c371ba832bb86289c51842aeb44e8e17c145991a94e29768104b202ef38f811ffbdef85ce3229a28b870f4677b643d9c34861ad3eb9b7e080cece0b5a1f449c460d7eb8b95018644b9908229db57db2662d7d56cedf01e4afb166256858cfcf099eafe5df3dd9f5583777fd4c362008a19004871078fce6746f70216c9b99cbd67dde40e037a1daae0fcb3eee8f5670ca0379b8446af7abcda2c82cefff1f84e315f01fd4051123b5f2632d9f7e1074a00f1244a8322687c3c3d009002d55537169c0cc9545860290a1eaed0878b3de9da733132f59d3e034e94506cd04e0a027034d326343c153ccd029ed1eb1edbfdd8556870e229dc9cf10d1000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      SismoConnectResponse({
        appId: 0x11b1de449c6c4adb0b5775b3868b28b3,
        namespace: bytes16(keccak256("main")),
        version: bytes32("sismo-connect-v1"),
        signedMessage: abi.encode(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
        proofs: proofs
      });
  }

  // simple sismoConnect with one claim and one auth
  function getSismoConnectResponse4(ICommitmentMapperRegistry commitmentMapperRegistry) external returns (SismoConnectResponse memory) {
    // update EdDSA public key for proof made in dev.beta environment
    commitmentMapperRegistry.updateCommitmentMapperEdDSAPubKey(getEdDSAPubKeyDevBeta());

    Claim memory claim = Claim({
      groupId: 0xe9ed316946d3d98dfcd829a53ec9822e,
      groupTimestamp: bytes16("latest"),
      value: 1,
      isSelectableByUser: true,
      claimType: ClaimType.GTE,
      extraData: ""
    });
    Claim[] memory claims = new Claim[](1);
    claims[0] = claim;

    Auth memory auth = Auth({authType: AuthType.VAULT, isAnon: false, isSelectableByUser: true, userId: 0, extraData: ""});
    Auth[] memory auths = new Auth[](1);
    auths[0] = auth;

    SismoConnectProof[] memory proofs = new SismoConnectProof[](2);
    proofs[0] = SismoConnectProof({
      claims: claims,
      auths: new Auth[](0),
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"13587ad7020da4d3623b2086d0ef2f7c43cd2ec364cb4bd1beba0c442ddbfba227738ff2ba5658cf248e1b2130fd4a2feba3501bee9e41705ea16ab9d4d808bf016f2e8ff11487e8bc73a589ce5321b79d7c91e0178592e4b437b36fe695e4881109474d3daaae382977fff6693811fe50f82c6c4279e37f0ca9c66a2f4015451c697c23c7d3ce17ccffaf89d61dcb0c055fedbc66f2bbebafd0240a7d7e186606cd1d8e223f1ea29c49213fa85a1c3e36e65465fd936772486f9eda2da91022223dc5ed683beaba57e828f1603f6283961b4447d49a89dcf0da21a2b12502881be357287507b71c78c46d916f5a95f7703c09f14c6df19eae15c6321bb7e929000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74260a00dba64ffb7337d649f33f9f060a7b485d4a3b9f3964c3419c384fa0352604f81599b826fa9b715033e76e5b2fdda881352a9b61360022e30ee33ddccad90744e9b92802056c722ac4b31612e1b1de544d5b99481386b162a0b59862e0850000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc0000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });
    proofs[1] = SismoConnectProof({
      claims: new Claim[](0),
      auths: auths,
      provingScheme: bytes32("hydra-s2.1"),
      proofData: hex"287bb0d3b16d260aca9f66476021fd383606533930329e40498fdaae787bcdf11839abec22e3a7a4cb0c1a90326a32e36870e76a73028fa21ca42e54c337ea1005b69e23305a7515806b69e9a651e4628cfa838db6be6a5c87145b711b3e69be10f919b72a2a5b145b97ac8a6b97933b921b064e2e639fdab9f118cadfcc2f18194289fd2cf228d4852f660df0dc972789b6567cb1e68ee82db569f1b55a8b98185453fafb40361673d4a23f356d12a68b4ce05e84722ad5fe8d2716465a514815071481c809c5c5fe2323772fea1647cf3bcf8d989b27b32dd06f0fe2c8704d1464383a2c7fa8a6203784ebdde5acfdaa21cdf20dce81a9de5784241c58a09f000000000000000000000000000000000000000000000000000000000000000009f60d972df499264335faccfc437669a97ea2b6c97a1a7ddf3f0105eda34b1d2ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000174c0f7d68550e40962c4ae6db9b04940288cb4aeede625dd8a9b0964939cdeb0000000000000000000000000000000011b1de449c6c4adb0b5775b3868b28b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
      extraData: ""
    });

    return
      SismoConnectResponse({
        appId: 0x11b1de449c6c4adb0b5775b3868b28b3,
        namespace: bytes16(keccak256("main")),
        version: bytes32("sismo-connect-v1"),
        signedMessage: abi.encode(0x7def1d6D28D6bDa49E69fa89aD75d160BEcBa3AE),
        proofs: proofs
      });
  }

}
