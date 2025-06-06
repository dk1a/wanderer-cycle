import { Hex, toHex } from "viem";
import { getRecord, getRecords } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";
import { parseArrayPStat, PStats } from "./experience";
import { Elemental, parseElementalArray } from "./elemental";
import { getLoot, LootData } from "./getLoot";

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

export interface CycleCombatRewardLog {
  requestId: Hex;
  exp: PStats;
  lootRewards: LootData[];
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
  withAttack: boolean;
  withSpell: boolean;
  attackDamage: Elemental;
  spellDamage: Elemental;
}

export const attackAction: CombatAction = {
  actionType: CombatActionType.ATTACK,
  actionEntity: toHex(0, { size: 32 }),
};

export function getCycleActiveCombat(state: StateLocal, cycleEntity: Hex) {
  const result = getRecord({
    state,
    table: mudTables.cycle__ActiveCombat,
    key: { entity: cycleEntity },
  });
  return result;
}

export function getCycleCombatRewardRequests(
  state: StateLocal,
  requesterEntity: Hex,
): CycleCombatRewardRequest[] {
  const requests = getRecords({
    state,
    table: mudTables.rng__RNGRequestOwner,
  });
  const filteredRequests = Object.values(requests).filter(
    ({ ownerEntity }) => ownerEntity === requesterEntity,
  );

  const result = [];
  for (const request of filteredRequests) {
    const precommit = getRecord({
      state,
      table: mudTables.rng__RNGPrecommit,
      key: request,
    });
    const combatRReq = getRecord({
      state,
      table: mudTables.cycle__CycleCombatRReq,
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

export function getCycleCombatRewardLog(
  state: StateLocal,
  combatEntity: Hex,
): CycleCombatRewardLog | undefined {
  const log = getRecord({
    state,
    table: mudTables.cycle__CombatRewardLogOffchain,
    key: { combatEntity },
  });
  if (!log) return;

  return {
    requestId: log.requestId,
    exp: parseArrayPStat(log.exp),
    lootRewards: log.lootEntities.map((lootEntity) =>
      getLoot(state, lootEntity),
    ),
  };
}

export function getCombatLog(
  state: StateLocal,
  combatEntity: Hex,
): CombatLog | undefined {
  const combatStatus = getRecord({
    state,
    table: mudTables.combat__CombatStatus,
    key: { entity: combatEntity },
  });
  const combatActors = getRecord({
    state,
    table: mudTables.combat__CombatActors,
    key: { entity: combatEntity },
  });
  if (!combatStatus?.isInitialized || !combatActors) return;

  const rounds: CombatRoundLog[] = [];
  for (
    let roundIndex = 0;
    roundIndex < combatStatus.roundsSpent;
    roundIndex++
  ) {
    const round = getCombatRoundLog(
      state,
      combatEntity,
      combatActors.initiatorEntity,
      combatActors.retaliatorEntity,
      roundIndex,
    );
    if (round === undefined) {
      console.warn(
        `Missing combat round log for: ${combatEntity} ${roundIndex}`,
      );
      continue;
    }

    rounds.push(round);
  }

  return {
    initiatorEntity: combatActors.initiatorEntity,
    retaliatorEntity: combatActors.retaliatorEntity,
    roundsSpent: Number(combatStatus.roundsSpent),
    roundsMax: Number(combatStatus.roundsMax),
    combatResult: combatStatus.combatResult,
    rounds,
  };
}

function getCombatRoundLog(
  state: StateLocal,
  combatEntity: Hex,
  initiatorEntity: Hex,
  retaliatorEntity: Hex,
  roundIndex: number,
): CombatRoundLog | undefined {
  const combatRoundLog = getRecord({
    state,
    table: mudTables.combat__CombatLogRoundOffchain,
    key: { entity: combatEntity, roundIndex: BigInt(roundIndex) },
  });
  if (!combatRoundLog) return;

  const initiatorActions: CombatActionLog[] = getCombatActionLogs(
    state,
    combatEntity,
    initiatorEntity,
    retaliatorEntity,
    roundIndex,
    combatRoundLog.initiatorActionLength,
  );
  const retaliatorActions: CombatActionLog[] = getCombatActionLogs(
    state,
    combatEntity,
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
  combatEntity: Hex,
  attackerEntity: Hex,
  defenderEntity: Hex,
  roundIndex: number,
  actionLength: bigint,
): CombatActionLog[] {
  const actions: CombatActionLog[] = [];
  for (let actionIndex = 0; actionIndex < actionLength; actionIndex++) {
    const action = getCombatActionLog(
      state,
      combatEntity,
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
  combatEntity: Hex,
  attackerEntity: Hex,
  defenderEntity: Hex,
  roundIndex: number,
  actionIndex: number,
): CombatActionLog | undefined {
  const combatActionLog = getRecord({
    state,
    table: mudTables.combat__CombatLogActionOffchain,
    key: {
      entity: combatEntity,
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
    withAttack: combatActionLog.withAttack,
    withSpell: combatActionLog.withSpell,
    attackDamage: parseElementalArray(combatActionLog.attackDamage),
    spellDamage: parseElementalArray(combatActionLog.spellDamage),
  };
}
