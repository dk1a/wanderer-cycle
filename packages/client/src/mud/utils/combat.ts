import { Hex, toHex } from "viem";
import { getRecord, getRecords } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";
import { parseArrayPStat, PStats } from "./experience";

export const MAX_ROUNDS = 12;

export interface CombatAction {
  actionType: CombatActionType;
  actionEntity: Hex;
}

export enum CombatActionType {
  ATTACK,
  SKILL,
}

export enum CombatResult {
  NONE,
  VICTORY,
  DEFEAT,
}

export interface CycleCombatRewardRequest {
  requestId: Hex;
  blocknumber: bigint;
  mapEntity: Hex;
  connection: number;
  fortune: number;
  winnerPStats: PStats;
  loserPStats: PStats;
}

export interface CombatLog {
  initiatorEntity: Hex;
  retaliatorEntity: Hex;
  roundsSpent: number;
  roundsMax: number;
  combatResult: CombatResult;

  rounds: CombatRoundLog[];
}

export interface CombatRoundLog {
  roundIndex: number;
  initiatorActions: CombatActionLog[];
  retaliatorActions: CombatActionLog[];
}

export interface CombatActionLog {
  actionIndex: number;
  action: CombatAction;
  defenderLifeDiff: number;
}

export const attackAction: CombatAction = {
  actionType: CombatActionType.ATTACK,
  actionEntity: toHex(0, { size: 32 }),
};

export function getActiveCombat(state: StateLocal, initiatorEntity: Hex) {
  const result = getRecord({
    state,
    table: mudTables.root__ActiveCombat,
    key: { initiatorEntity },
  });
  return result;
}

export function getCycleCombatRewardRequests(
  state: StateLocal,
  requesterEntity: Hex,
): CycleCombatRewardRequest[] {
  const requests = getRecords({
    state,
    table: mudTables.root__RNGRequestOwner,
  });
  const filteredRequests = Object.values(requests).filter(
    ({ ownerEntity }) => ownerEntity === requesterEntity,
  );

  const result = [];
  for (const request of filteredRequests) {
    const precommit = getRecord({
      state,
      table: mudTables.root__RNGPrecommit,
      key: request,
    });
    const combatRReq = getRecord({
      state,
      table: mudTables.root__CycleCombatRReq,
      key: request,
    });
    if (precommit === undefined || combatRReq === undefined) {
      console.warn(
        `Combat reward request ${request.requestId} is incomplete: ${precommit} ${combatRReq}`,
      );
      continue;
    }

    result.push({
      requestId: request.requestId,
      blocknumber: precommit.value,
      mapEntity: combatRReq.mapEntity,
      connection: combatRReq.connection,
      fortune: combatRReq.fortune,
      winnerPStats: parseArrayPStat(combatRReq.winnerPStat),
      loserPStats: parseArrayPStat(combatRReq.loserPStat),
    });
  }
  return result;
}

export function getCombatLog(
  state: StateLocal,
  initiatorEntity: Hex,
  retaliatorEntity: Hex,
): CombatLog {
  const combatLog = getRecord({
    state,
    table: mudTables.root__CombatLogOffchain,
    key: { initiatorEntity, retaliatorEntity },
  });
  if (combatLog === undefined) {
    return {
      initiatorEntity,
      retaliatorEntity,
      roundsSpent: 0,
      roundsMax: 0,
      combatResult: CombatResult.NONE,
      rounds: [],
    };
  }

  const rounds: CombatRoundLog[] = [];
  for (let roundIndex = 0; roundIndex < combatLog.roundsSpent; roundIndex++) {
    const round = getCombatRoundLog(
      state,
      initiatorEntity,
      retaliatorEntity,
      roundIndex,
    );
    if (round === undefined) {
      console.warn(
        `Missing combat round log for: ${initiatorEntity} ${retaliatorEntity} ${roundIndex}`,
      );
      continue;
    }

    rounds.push(round);
  }

  return {
    initiatorEntity,
    retaliatorEntity,
    roundsSpent: Number(combatLog.roundsSpent),
    roundsMax: Number(combatLog.roundsMax),
    combatResult: combatLog.combatResult,
    rounds,
  };
}

function getCombatRoundLog(
  state: StateLocal,
  initiatorEntity: Hex,
  retaliatorEntity: Hex,
  roundIndex: number,
): CombatRoundLog | undefined {
  const combatRoundLog = getRecord({
    state,
    table: mudTables.root__CombatLogRoundOffchain,
    key: { initiatorEntity, retaliatorEntity, roundIndex: BigInt(roundIndex) },
  });
  if (!combatRoundLog) return;

  const initiatorActions: CombatActionLog[] = getCombatActionLogs(
    state,
    initiatorEntity,
    retaliatorEntity,
    roundIndex,
    combatRoundLog.initiatorActionLength,
  );
  const retaliatorActions: CombatActionLog[] = getCombatActionLogs(
    state,
    retaliatorEntity,
    initiatorEntity,
    roundIndex,
    combatRoundLog.retaliatorActionLength,
  );

  return {
    roundIndex: Number(combatRoundLog.roundIndex),
    initiatorActions,
    retaliatorActions,
  };
}

function getCombatActionLogs(
  state: StateLocal,
  attackerEntity: Hex,
  defenderEntity: Hex,
  roundIndex: number,
  actionLength: bigint,
): CombatActionLog[] {
  const actions: CombatActionLog[] = [];
  for (let actionIndex = 0; actionIndex < actionLength; actionIndex++) {
    const action = getCombatActionLog(
      state,
      attackerEntity,
      defenderEntity,
      roundIndex,
      actionIndex,
    );
    if (action === undefined) {
      console.warn(
        `Missing combat action log for: ${attackerEntity} ${defenderEntity} ${roundIndex} ${actionIndex}`,
      );
      continue;
    }

    actions.push(action);
  }
  return actions;
}

function getCombatActionLog(
  state: StateLocal,
  attackerEntity: Hex,
  defenderEntity: Hex,
  roundIndex: number,
  actionIndex: number,
): CombatActionLog | undefined {
  const combatActionLog = getRecord({
    state,
    table: mudTables.root__CombatLogActionOffchain,
    key: {
      attackerEntity,
      defenderEntity,
      roundIndex: BigInt(roundIndex),
      actionIndex: BigInt(actionIndex),
    },
  });
  if (combatActionLog === undefined) return;

  return {
    actionIndex,
    action: {
      actionType: combatActionLog.actionType,
      actionEntity: combatActionLog.actionEntity,
    },
    defenderLifeDiff:
      combatActionLog.defenderLifeAfter - combatActionLog.defenderLifeBefore,
  };
}
