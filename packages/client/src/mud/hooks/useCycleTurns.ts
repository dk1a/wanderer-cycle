import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { BigNumber } from "ethers";

const ACC_PERIOD = 1;
const TURNS_PER_PERIOD = 10;
const MAX_ACC_PERIODS = 2;
const MAX_CURRENT_TURNS_FOR_CLAIM = 50;
export const useCycleTurns = (entity: EntityIndex | undefined) => {
  const {
    components: { CycleTurns },
  } = useMUD();

  const cycleTurns = useComponentValue(CycleTurns, entity);
  return cycleTurns?.value;
};

export const useCycleTurnsLastClaimedComponent = (entity: EntityIndex | undefined) => {
  const {
    components: { CycleTurnsLastClaimed },
  } = useMUD();

  const cycleTurnsLastClaimed = useComponentValue(CycleTurnsLastClaimed, entity);
  return BigNumber.from(cycleTurnsLastClaimed?.value).toNumber();
};

function _getAccPeriods(entity: EntityIndex | undefined) {
  const {
    components: { CycleTurnsLastClaimed },
  } = useMUD();

  const lastClaimedTimestamp = useComponentValue(CycleTurnsLastClaimed, entity);
  const lastClaimedTimestampValue = BigNumber.from(lastClaimedTimestamp?.value).toNumber();
  if (lastClaimedTimestampValue == 0) {
    return 1;
  }
  const periodsLast = Math.floor(lastClaimedTimestampValue / ACC_PERIOD);
  const periodsCurrent = Math.floor((Date.now() * 0.001) / ACC_PERIOD);
  const accPeriods = periodsCurrent - periodsLast;
  if (accPeriods > MAX_ACC_PERIODS) {
    return MAX_ACC_PERIODS;
  } else {
    return accPeriods;
  }
}

export const useGetClaimableTurns = (entity: EntityIndex | undefined) => {
  const accumulatedTurns = TURNS_PER_PERIOD * _getAccPeriods(entity);
  if (accumulatedTurns <= TURNS_PER_PERIOD * MAX_ACC_PERIODS) {
    throw new Error("Error");
  }
  const currentTurns = useCycleTurns(entity);
  if (currentTurns == undefined || currentTurns > MAX_CURRENT_TURNS_FOR_CLAIM) {
    return 0;
  } else {
    return accumulatedTurns;
  }
};
