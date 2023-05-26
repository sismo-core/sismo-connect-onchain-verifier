import { DevGroup } from "@sismo-core/sismo-connect-client";
import { newSismoConnectClientConfig } from "./../../../typescript/configuration/compute-solidity-config";

export const config: newSismoConnectClientConfig = {
  appId: "0xf4977993e52606cfd67b7a1cde717069",
  vault: "devVault",
  customGroups: [
    {
      // Nouns DAO NFT Holders group : https://factory.sismo.io/groups-explorer?search=0x311ece950f9ec55757eb95f3182ae5e2
      groupId: "0x311ece950f9ec55757eb95f3182ae5e2",
      data: [
        // your address is added here so you can test the airdrops
        "0x2b9b9846d7298e0272c61669a54f0e602aba6290",
        "0xb01ee322c4f028b8a6bfcd2a5d48107dc5bc99ec",
        "0x938f169352008d35e065F153be53b3D3C07Bcd90",
      ],
    },
    {
      // Gitcoin Passport group : https://factory.sismo.io/groups-explorer?search=0x1cde61966decb8600dfd0749bd371f12
      groupId: "0x1cde61966decb8600dfd0749bd371f12",
      // data can also be an object with the address as key and the score as value
      // here we give a score to 15 to all addresses to be eligible in the tutorial
      data: {
        // your address is added here so you can test the airdrops
        "0x2b9b9846d7298e0272c61669a54f0e602aba6290": 15,
        "0xb01ee322c4f028b8a6bfcd2a5d48107dc5bc99ec": 15,
        "0x938f169352008d35e065F153be53b3D3C07Bcd90": 15,
      },
    },
  ] as DevGroup[],
};

console.log(JSON.stringify(config));
