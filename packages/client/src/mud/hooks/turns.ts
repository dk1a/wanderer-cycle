import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { BigNumber } from "ethers";
import { useState } from "react";

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

// TODO central config for these
const ACC_PERIOD = 1;
const TURNS_PER_PERIOD = 10;
const MAX_ACC_PERIODS = 2;
const MAX_CURRENT_TURNS_FOR_CLAIM = 50;

export const useGetClaimableTurns = (entity: EntityIndex | undefined) => {
  const accumulatedTurns = TURNS_PER_PERIOD * useAccPeriods(entity);
  const currentTurns = useCycleTurns(entity);
  if (currentTurns == undefined || currentTurns > MAX_CURRENT_TURNS_FOR_CLAIM) {
    return 0;
  } else {
    return accumulatedTurns;
  }
};

function useAccPeriods(entity: EntityIndex | undefined) {
  const {
    components: { CycleTurnsLastClaimed },
  } = useMUD();

  const [timestamp, setTimestamp] = useState(Date.now() * 0.001);

  const lastClaimedTimestamp = useComponentValue(CycleTurnsLastClaimed, entity);
  if (lastClaimedTimestamp === undefined) return 1;
  const lastClaimedTimestampValue = BigNumber.from(lastClaimedTimestamp?.value).toNumber();
  if (lastClaimedTimestampValue == 0) return 1;

  const periodsLast = Math.floor(lastClaimedTimestampValue / ACC_PERIOD);
  const periodsCurrent = Math.floor(timestamp / ACC_PERIOD);
  const accPeriods = periodsCurrent - periodsLast;

  if (accPeriods > MAX_ACC_PERIODS) {
    return MAX_ACC_PERIODS;
  } else {
    return accPeriods;
  }
}
