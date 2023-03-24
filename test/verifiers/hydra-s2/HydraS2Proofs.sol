// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "forge-std/console.sol";
import "src/libs/utils/Struct.sol";
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
    function getZkConnectResponse1() public pure returns (ZkConnectResponse memory) {
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
            signedMessage: "",
            provingScheme: bytes32("hydra-s2.1"),
            proofData: hex"162fba0e2b357e6190d05471c08a4f4da6d0831bcefd8f7787d732d3156698d4119664dd2bfcc0d9b0d3513947fa1e20f9f73847c89ddc9f336476eea1106d03070eca2658f85ee8f9845aac26de7ad4ffccc78713f7dd2efb9024e0ef8750090c1f8c411c43ab85f6fe6cfbe53d1c5c3e90e322027bc12975fd96f02566cf1e12f139fd40095f34f8e0603cbe43efc2f03f32c638a94f8fb5f55f2252f48f0112bcbedd222aa50a515826acf4bda6fe381fa651f5b719c0510b81316bd4d1e02c65015a5fa1ae041d5682b490abdc864970b1c3178adbbd7d024ebbc9b06bae3002d7663bc44ebb4ac8567f0e6968dab8e4f479ffb45dc939d4b624392ee1e40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f6c5612eb579788478789deccb06cf0eb168e457eea490af754922939ebdb920706798455f90ed993f8dac8075fc1538738a25f0c928da905c0dffd81869fa1d4a72bd1c1e4f9ab68c3c4c55afd3e582685a18b9ec09fc96136619d2513fe821a63725868405196971cad8f2e46ed111118a9869929d0f87c154c9c60d015f044f025508bb2ec3ad43852788f4f9f74c37ece5e1958c59b4558e7b098768510000000000000000000000000000000000000000000000000000000000000001285bf79dc20d58e71b9712cb38c420b9cb91d3438c8e3dbaf07829b03ffffffc000000000000000000000000000000000000000000000000000000000000000028c8b31cfdb3021f44a90006d40ee6ff1d1080103a6704b0ba79f0493281599f00000000000000000000000000000000112a692a2005259c25f609416100796700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000",
            extraData: ""
        });

        return ZkConnectResponse({
            appId: 0x112a692a2005259c25f6094161007967,
            namespace: bytes16(keccak256("main")),
            version: bytes32("zk-connect-v1"),
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
            proofData: hex"2e87cd51ce71e3ae03e4a4fec4b188ed2f0c0cf4b0bdc7e5b644c31a7ae93c9e1fc89b2823e9032478890a0d9152dec9886f2b0858455a99a5a73a2c5735cb0e0188d8e657e05eefb57773ae38c6a3ae8fcfa645796614c8982f0dec90342aff1a080b67f3fcaf89c214c2938a97b76312f81efb2343d308394816efc8e4d56314455e88887214dcaa73041ff0ae3cb2bd76e3eca126fe51d2f59a8d892bbd8b1fb3bc87290ab379abf901cef3f188f9dd51c570afd46db750b475ef4e1c11ef241d56a523f7c49aad74b6a178f1f5dde45b20a218c318dbf0d0a6d527b8e20e0bcbff6fdbfe12e70d53c7c7988a3b1f57553efdf9a97106ccc43671fc5de990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002ab71fb864979b71106135acfa84afc1d756cda74f8f258896f896b4864f025630423b4c502f1cd4179a425723bf1e15c843733af2ecdee9aef6a0451ef2db74000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000248e23b0ab81418b9c5d6a2da3cf7a45e67e7624f716a395bec6c8d53ce15a1400000000000000000000000000000000112a692a2005259c25f609416100796700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            extraData: ""
        });

        return ZkConnectResponse({
            appId: 0x112a692a2005259c25f6094161007967,
            namespace: bytes16(keccak256("main")),
            version: bytes32("zk-connect-v1"),
            proofs: proofs
        });
    }
}

// zkConnectResponse={"appId":"0x112a692a2005259c25f6094161007967","namespace":"main","verifiableStatements":[{"groupId":"0xe9ed316946d3d98dfcd829a53ec9822e","value":1,"groupTimestamp":"latest","comparator":"GTE","extraData":null,"provingScheme":"hydra-s2.1","proof":{"input":["0","0","3602196582082511412345093208859330584743530098298494929484637038525722574265","14672613011011178056703002414016466661118036128791343632962870104486584019450","13248611189182993289112986308655530576602761144405261658918024840764458090472","15220001223734259708794025134837761980974298402159981363142196430800432202079","1948848408458219023298847550719312852455121665580000720459610747046315124817","1","18255006010720847855577282464024487725515892822905365243907163690393434849276","0","18447119550478564123220367642251321196495840786123843857934163943441788131743","22817085386902984175628135281532631399","1","0"],"a":["10035208587686635556432700232565779213829501560906643905611872199504837384404","7955041623047583975884660376488022261665017004404505739027848139658497125635"],"b":[["3192320985599442608805658710818450419896966508522449925474882449599111843849","5483494441868992613789901777797721498574736345872569442909238967251826560798"],["8567841644262501509064722169755087348602825209973739811877521117142976859905","8475115816229395816218196553721703309009339733441942703480757801692723204576"]],"c":["20080226229419063639828128333248745521194951849941176435659177649360201608110","21716037057799644879731036919229017249963592340354501423639650460705156424164"]}}],"version":"zk-connect-v1"}

//     this.input = ["0","0","3602196582082511412345093208859330584743530098298494929484637038525722574265","14672613011011178056703002414016466661118036128791343632962870104486584019450","13248611189182993289112986308655530576602761144405261658918024840764458090472","15220001223734259708794025134837761980974298402159981363142196430800432202079","1948848408458219023298847550719312852455121665580000720459610747046315124817","1","18255006010720847855577282464024487725515892822905365243907163690393434849276","0","18447119550478564123220367642251321196495840786123843857934163943441788131743","22817085386902984175628135281532631399","1","0"].map(x=>BigNumber.from(x));

// zkConnectResponse2 = {"appId":"0x112a692a2005259c25f6094161007967","namespace":"main","verifiableStatements":[],"version":"zk-connect-v1","authProof":{"provingScheme":"hydra-s2.1","proof":{"input":["0","0","19320691578712166656194071001997979369784273223372627996297303737574513115734","21828037898706931692006780079505701324195276460393510989179851793239087700852","0","0","0","0","0","0","16534401156330446369106624189465821635324268642307826322699421000773046196756","22817085386902984175628135281532631399","0","0"],"a":["21046332452073291309159216882313864310966895651657629422673957296875558747294","14376138571900340027511126869962168876482142155204114342365195129039854357262"],"b":[["694101036646237050849377487719521483077222979294471908870232011915715160831","11774347561462310326510825175414258855461305841269661046656277785763463353699"],["9168821864213783402400864627227119380716956848348781389402201235890209799563","14339265102904791651357007181715874505609370337162877773265243855736952066543"]],"c":["16335099116241043240936425502667554008456949640591884749127683791139844448782","5335874249606365728524789871762965052805334466462915882762398425575052929424"]}}}

// export function toBytes(snarkProof: any) {
//     return ethers.AbiCoder.defaultAbiCoder().encode(
//         ['uint256[2]', 'uint256[2][2]', 'uint256[2]', 'uint256[14]'],
//         [snarkProof.a, snarkProof.b, snarkProof.c, snarkProof.input]
//     )
// }

// toBytes(zkConnectResponse2.authProof.proof)
