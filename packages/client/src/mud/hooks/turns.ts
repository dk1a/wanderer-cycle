import { useEffect, useMemo, useState } from "react";
import { useComponentValue } from "@latticexyz/react";
import { Entity } from "@latticexyz/recs";
import { useMUD } from "../../MUDContext";

export const useCycleTurns = (entity: Entity | undefined) => {
  const {
    components: { CycleTurns },
  } = useMUD();

  const cycleTurns = useComponentValue(CycleTurns, entity);
  return cycleTurns?.value;
};

// TODO central config for these
const ACC_PERIOD = 1 * 60;
const TURNS_PER_PERIOD = 10;
const MAX_ACC_PERIODS = 2;
const MAX_CURRENT_TURNS_FOR_CLAIM = 50;

export const useGetClaimableTurns = (entity: Entity | undefined) => {
  const accumulatedTurns = TURNS_PER_PERIOD * useAccPeriods(entity);
  const currentTurns = useCycleTurns(entity);
  if (currentTurns == undefined || currentTurns > MAX_CURRENT_TURNS_FOR_CLAIM) {
    return 0;
  } else {
    return accumulatedTurns;
  }
};

function useAccPeriods(entity: Entity | undefined) {
  const {
    components: { CycleTurnsLastClaimed },
  } = useMUD();

  const [timestamp, setTimestamp] = useState(Date.now() * 0.001);

  const lastClaimed = useComponentValue(CycleTurnsLastClaimed, entity);
  const lastClaimedTimestamp = useMemo(() => {
    let lastClaimedTimestamp = 0;
    if (lastClaimed) {
      lastClaimedTimestamp = lastClaimed.value;
    }
    if (lastClaimedTimestamp === 0) {
      lastClaimedTimestamp = timestamp - ACC_PERIOD * 1000;
    }
    return lastClaimedTimestamp;
  }, [lastClaimed, timestamp]);

  const periodsLast = Math.floor(lastClaimedTimestamp / ACC_PERIOD);
  const periodsCurrent = Math.floor(timestamp / ACC_PERIOD);
  const accPeriods = periodsCurrent - periodsLast;

  useEffect(() => {
    const nextRefresh =
      ((periodsLast + 1) * ACC_PERIOD - lastClaimedTimestamp) * 1000 + 1000;

    const timeout = setTimeout(() => {
      setTimestamp(Date.now() * 0.001);
    }, nextRefresh);

    return () => clearTimeout(timeout);
  }, [periodsLast, lastClaimedTimestamp]);

  if (accPeriods > MAX_ACC_PERIODS) {
    return MAX_ACC_PERIODS;
  } else {
    return accPeriods;
  }
}
