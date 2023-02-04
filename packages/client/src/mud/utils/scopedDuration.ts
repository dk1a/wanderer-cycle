import { BigNumber } from "ethers";

export interface ScopedDuration {
  timeScopeId: string;
  timeValue: number;
}

export const parseScopedDuration = (timeScopeId: string, timeValue: string): ScopedDuration => {
  return {
    timeScopeId,
    // seconds
    timeValue: BigNumber.from(timeValue).toNumber(),
  };
}