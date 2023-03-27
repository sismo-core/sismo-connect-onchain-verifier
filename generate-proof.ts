export type devConfig = {
  devAddresses: string[];
};

export type ZkConnectRequest = {
  appId: string;
  namespace: string;
  requestContent: ZkConnectRequestContent; // updated
  callbackPath: string;
  version: string;
};

export type ZkConnectRequestContent = {
  dataRequests: DataRequest[];
  // should be dataRequests.length - 1 and all the same for now
  operators: LogicalOperator[]; // Default AND
};
export type LogicalOperator = "AND" | "OR";

export type DataRequest = {
  authRequest?: Auth;
  claimRequest?: Claim;
  messageSignatureRequest?: any;
};

// I request higher than 3 ("3", "GTE");
// I request any value from my user ("ANY", "EQUAL");
export type Claim = {
  groupId: string;
  groupTimestamp: number | "latest"; // default to "latest"
  value: number; // default to 1
  claimType: ClaimType; // default to GTE
  extraData: any; // default to ''
};

export enum ClaimType {
  GTE,
  GT,
  EQ,
  LT,
  LTE,
  USER_SELECT,
}

export type Auth = {
  // twitter// github// evmAccount
  authType: AuthType;
  // if anonMode == true, user does not reveal the Id
  // they only prove ownership of one account of this type in the vault
  anonMode: boolean; // anonMode default false;
  // githubAccount / twitter account / ethereum address
  // if userId == 0, user can chose any userId
  userId: string; // default 0
  extraData: any; // default ''
};

export enum AuthType {
  NONE,
  ANON,
  GITHUB,
  TWITTER,
  EVM_ACCOUNT,
}

export type ZkConnectResponse = Pick<ZkConnectRequest, "appId" | "namespace" | "version"> & {
  proofs: ZkConnectProof[];
};

export type ZkConnectProof = {
  auth: Auth;
  claim: Claim;
  provingScheme: string;
  signedMessage: string | any;
  proofData: string;
  proofId: string;
  extraData: any;
};

//Return by the zkConnect.verify
export type ZkConnectVerifiedResult = Omit<ZkConnectResponse, "proofs"> & {
  signedMessages: string[];
  verifiedClaims: VerifiedClaim[];
  verifiedAuths: VerifiedAuth[];
};

export type VerifiedClaim = Claim & {
  proofId: string;
  __proof: string;
};

export type VerifiedAuth = Auth & {
  proofId: string;
  __proof: string;
};

export const dataRequestMock1: DataRequest = {
  claimRequest: {
    groupId: "0x1720d8b16c052df89d805d3455d71447",
    groupTimestamp: "latest",
    value: 1,
    claimType: 0,
    extraData: "",
  },
  messageSignatureRequest: "my custom message",
};

export const dataRequestMock2: DataRequest = {
  claimRequest: {
    groupId: "0x42c768bb8ae79e4c5c05d3b51a4ec74a",
    groupTimestamp: "latest",
    value: 5,
    claimType: 2,
    extraData: "",
  },
  messageSignatureRequest: "my custom message",
};

export const zkConnectRequestContentMock: ZkConnectRequestContent = {
  dataRequests: [dataRequestMock1, dataRequestMock2],
  operators: ["AND"],
};

export const zkConnectRequestMock: ZkConnectRequest = {
  appId: "0x37bb3224298ac0e3ac3cb78a1caa292b",
  namespace: "main",
  version: "off-chain-1",
  requestContent: zkConnectRequestContentMock,
  callbackPath: "/",
};

const url = new URL("http://localhost:3000/connect");
const searchParams = url.searchParams;
searchParams.set("version", zkConnectRequestMock.version);
searchParams.set("appId", zkConnectRequestMock.appId);
searchParams.set("namespace", zkConnectRequestMock.namespace);
searchParams.set("callbackPath", zkConnectRequestMock.callbackPath);
searchParams.set("requestContent", JSON.stringify(zkConnectRequestContentMock));

export const zkConnectRequestMockUrl = url.toString();

// import opn from "better-opn";

// opn("http://localhost:3000");

const opn = require("better-opn");
console.log("zkConnectRequestMockUrl", zkConnectRequestMockUrl);
opn(zkConnectRequestMockUrl);
