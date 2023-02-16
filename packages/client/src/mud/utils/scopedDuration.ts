import { BigNumber } from "ethers";
import { keccak256, toUtf8Bytes } from "ethers/lib/utils";

export interface ScopedDuration {
  timeScopeId: string;
  timeScopeName: string;
  timeValue: number;
}

export const parseScopedDuration = (timeScopeId: string, timeValue: string): ScopedDuration => {
  return {
    timeScopeId,
    timeScopeName: timeScopeIdToName[timeScopeId],
    // seconds
    timeValue: BigNumber.from(timeValue).toNumber(),
  };
};

// TODO unhardcode this (start with the contracts side)
const timeScopeIdToName = {
  [keccak256(toUtf8Bytes("turn"))]: "turn",
  [keccak256(toUtf8Bytes("round"))]: "round",
  [keccak256(toUtf8Bytes("round_persistent"))]: "round_persistent",
};
