import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";

export function getCycleTurns(state: StateLocal, entity: Hex | undefined) {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.cycle__CycleTurns,
    key: {
      entity,
    },
  })?.value;
}

// TODO central config for these
const ACC_PERIOD = 1 * 60;
const TURNS_PER_PERIOD = 10;
const MAX_ACC_PERIODS = 2;
const MAX_CURRENT_TURNS_FOR_CLAIM = 50;

export function getClaimableTurns(
  state: StateLocal,
  entity: Hex,
  accPeriods: number,
) {
  const accumulatedTurns = TURNS_PER_PERIOD * accPeriods;
  const currentTurns = getCycleTurns(state, entity);
  if (currentTurns == undefined || currentTurns > MAX_CURRENT_TURNS_FOR_CLAIM) {
    return 0;
  } else {
    return accumulatedTurns;
  }
}

export function getAccPeriods(
  state: StateLocal,
  entity: Hex,
  timestamp: number,
) {
  const lastClaimed = getRecord({
    state,
    table: mudTables.cycle__CycleTurnsLastClaimed,
    key: { entity },
  });

  let lastClaimedTimestamp = Number(lastClaimed?.value ?? 0);
  // Convert seconds to ms
  lastClaimedTimestamp *= 1000;
  // Calculate the default value if nothing is saved
  if (lastClaimedTimestamp === 0) {
    lastClaimedTimestamp = timestamp - ACC_PERIOD;
  }

  const periodsLast = Math.floor(lastClaimedTimestamp / ACC_PERIOD);
  const periodsCurrent = Math.floor(timestamp / ACC_PERIOD);

  let accPeriods = periodsCurrent - periodsLast;
  if (accPeriods > MAX_ACC_PERIODS) {
    accPeriods = MAX_ACC_PERIODS;
  }

  return {
    accPeriods,
    nextClaimableTimestamp: (periodsCurrent + 1) * ACC_PERIOD * 1000,
  };
}
