import {
  AuthRequest,
  ClaimRequest,
  DevAddresses,
  DevGroup,
  SismoConnectClientConfig,
} from "@sismo-core/sismo-connect-client";
import { encodeAbiParameters } from "viem";
import { getRegistryTreeRoot } from "./compute-tree";

export type newSismoConnectClientConfig = {
  appId: string;
  authRequests?: AuthRequest[];
  claimRequests?: ClaimRequest[];
  vaultEnv?: "prod" | "dev";
  customGroups?: CustomGroup[];
  displayRawResponse?: boolean;
  sismoApiUrl?: string;
  vaultAppBaseUrl?: string;
};

export type CustomGroup = DevGroup;

export type SolidityConfig = {
  appId: `0x${string}`;
  devMode: boolean;
  registryTreeRoot: bigint;
  devGroups: {
    groupId: `0x${string}`;
    // data: {
    //   address: `0x${string}`;
    //   value: bigint;
    // }[];
  }[];
};

const computeSolityData = (data: DevAddresses): { address: `0x${string}`; value: bigint }[] => {
  if (Array.isArray(data)) {
    return data.map((address) => ({ address: address as `0x${string}`, value: BigInt(1) }));
  } else {
    return Object.entries(data).map(([address, value]) => ({
      address: address as `0x${string}`,
      value: BigInt(value.toString()),
    }));
  }
};

const computeSolidityConfig = async (rawConfig: string): Promise<SolidityConfig> => {
  const config = JSON.parse(rawConfig) as newSismoConnectClientConfig;
  const root = await getRegistryTreeRoot(config.customGroups ?? ([] as DevGroup[]));

  return {
    appId: config.appId as `0x${string}`,
    devMode: (config.vaultEnv ?? false) === "dev",
    registryTreeRoot: BigInt(root),
    devGroups:
      config.customGroups === undefined
        ? []
        : config.customGroups.map((group) => ({
            groupId: group.groupId as `0x${string}`,
          })),
  };
};

const main = async () => {
  // encode with viem
  const encodedConfig = encodeAbiParameters(
    [
      {
        name: "sismoConnectConfig",
        type: "tuple",
        components: [
          { name: "appId", type: "bytes16" },
          {
            name: "devMode",
            type: "bool",
          },
          {
            name: "registryTreeRoot",
            type: "uint256",
          },
          {
            name: "devGroups",
            type: "tuple[]",
            components: [
              {
                name: "groupId",
                type: "bytes16",
              },
            ],
          },
        ],
      },
    ],
    [await computeSolidityConfig(process.argv[2] as unknown as string)]
  );

  console.log(encodedConfig);
};

main();
