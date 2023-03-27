/** ********************************************* */
/** ********* ZK CONNECT PACKAGE TYPES ********** */
/** ********************************************* */

// TODO RENAME STATEMENT TO CLAIM
// TODO VERIFY COHERENCE WITH ON CHAIN STRUCT

export type ZkConnectRequest = {
  appId: string;
  namespace?: string;
  requestContent?: ZkConnectRequestContent;
  callbackPath?: string;
  version: string;
};

export type ZkConnectRequestContent = {
  dataRequests: DataRequest[];
  // should be dataRequests.length - 1 and all the same for now
  operators: LogicalOperator[];
};

export type LogicalOperator = "AND" | "OR";

export type DataRequest = {
  authRequest: Auth;
  claimRequest: Claim;
  messageSignatureRequest: any;
};

// I request higher than 3 ("3", "GTE");
// I request any value from my user ("ANY", "EQUAL");
export type Claim = {
  groupId: string;
  groupTimestamp?: number | "latest"; // default to "latest"
  value?: number;
  claimType?: ClaimType;
  extraData?: any;
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
  anonMode: boolean;
  // githubAccount / twitter account / ethereum address
  // if userId == 0, user can chose any userId
  userId: string;
  extraData: any;
};

export enum AuthType {
  NONE,
  ANON,
  GITHUB,
  TWITTER,
  EVM_ACCOUNT,
}

export type ZkConnectResponse = Pick<ZkConnectRequest, "appId" | "namespace" | "version"> & {
  authProof?: any;
  signedMessage?: string | any;
  proofs: ZkConnectProof[];
};

export type ZkConnectProof = {
  claim: Claim;
  auth: Auth;
  provingScheme: string;
  signedMessage: string;
  proofData: string;
  proofId: string;
  extraData: any;
};

export type ZkConnectVerifiedResult = ZkConnectResponse & {
  vaultId: string;
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
