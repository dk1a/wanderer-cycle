import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";
import { Elemental, parseElemental } from "../utils/elemental";
import {
  expToLevel,
  getAggregateExperience,
  parseArrayPStat,
  pstatNames,
  PStats,
  pstatsFromExperience,
} from "../utils/experience";
import { ELE_STAT, PSTAT } from "contracts/enums";
import { getValuesElementalFinal, getValuesFinal } from "./statmod";

export function getExperience(state: StateLocal, entity: Hex) {
  const result = getRecord({
    state,
    table: mudTables.root__Experience,
    key: {
      entity,
    },
  });
  if (result === undefined) return undefined;
  return parseArrayPStat(result.arrayPStat);
}

export function getPStats(state: StateLocal, targetEntity: Hex) {
  const pstats = [];
  for (const pstatName of Object.values(PSTAT) as PSTAT[]) {
    pstats.push(getPStat(state, targetEntity, pstatName));
  }
  return pstats;
}

export function getPStat(state: StateLocal, targetEntity: Hex, key: PSTAT) {
  const basePStat = getBasePStat(state, targetEntity, key);

  // Statmods can affect a specific pstat
  const pstat = getValuesFinal(state, targetEntity, pstatNames[key], 0);
  return {
    name: pstatNames[key],
    baseLevel: basePStat,
    buffedLevel: basePStat + pstat,
    experience: getExperience(state, targetEntity)?.[key],
  };
}

function getBasePStat(state: StateLocal, targetEntity: Hex, key: PSTAT) {
  // Some entities (players) have experience
  const experience = getExperience(state, targetEntity);
  if (experience !== undefined) {
    return pstatsFromExperience(experience)[key];
  }

  // Others may have a directly-set level
  const directLevel = getValuesFinal(state, targetEntity, "level", 0);
  return directLevel;
}

export interface LevelData {
  level: number | undefined;
  experience: number | undefined;
}

export function getLevel(
  state: StateLocal,
  targetEntity: Hex | undefined,
  levelMul: PStats | undefined,
) {
  if (targetEntity === undefined) {
    return {
      level: undefined,
      experience: undefined,
    };
  }

  // Some entities (players) have experience
  const experience = getExperience(state, targetEntity);
  if (experience !== undefined) {
    if (levelMul === undefined) {
      return {
        level: undefined,
        experience: undefined,
      };
    }

    const aggregateExperience = getAggregateExperience(experience, levelMul);
    return {
      level: expToLevel(aggregateExperience),
      experience: aggregateExperience,
    };
  }

  // Others may have a directly-set level
  const directLevel = getValuesFinal(state, targetEntity, "level", 0);
  return {
    level: directLevel,
    experience: undefined,
  };
}

// TODO this duplicates LibCharstat.sol
export function getLife(state: StateLocal, targetEntity: Hex | undefined) {
  if (targetEntity === undefined) return;
  const strength = getPStat(state, targetEntity, PSTAT.STRENGTH);

  const baseValue = 2 + 2 * strength.buffedLevel;
  return getValuesFinal(state, targetEntity, "life", baseValue);
}

export function getMana(state: StateLocal, targetEntity: Hex | undefined) {
  if (targetEntity === undefined) return;
  const arcana = getPStat(state, targetEntity, PSTAT.ARCANA);

  const baseValue = 4 * arcana.buffedLevel;
  return getValuesFinal(state, targetEntity, "mana", baseValue);
}

export function getAttack(state: StateLocal, targetEntity: Hex | undefined) {
  if (targetEntity === undefined) return;
  const strength = getPStat(state, targetEntity, PSTAT.STRENGTH);
  // strength increases physical base attack damage
  const baseValues = parseElemental(
    0,
    Math.floor(strength.buffedLevel / 2) + 1,
    0,
    0,
    0,
  );

  return getValuesElementalFinal(state, targetEntity, "attack", baseValues);
}

export function getResistance(
  state: StateLocal,
  targetEntity: Hex | undefined,
) {
  if (targetEntity === undefined) return;
  const dexterity = getPStat(state, targetEntity, PSTAT.DEXTERITY);
  const baseValues = parseElemental(
    Math.floor(dexterity.buffedLevel / 4) * 4,
    0,
    0,
    0,
    0,
  );

  return getValuesElementalFinal(state, targetEntity, "resistance", baseValues);
}

export function getSpell(
  state: StateLocal,
  targetEntity: Hex | undefined,
  baseValues: Elemental,
) {
  if (targetEntity === undefined) return;
  const arcana = getPStat(state, targetEntity, PSTAT.ARCANA);

  const buffedBaseValues = { ...baseValues };
  for (const eleStat of Object.values(ELE_STAT) as ELE_STAT[]) {
    if (baseValues[eleStat] > 0) {
      buffedBaseValues[eleStat] += arcana.buffedLevel;
    }
  }
  return getValuesElementalFinal(
    state,
    targetEntity,
    "spell",
    buffedBaseValues,
  );
}
