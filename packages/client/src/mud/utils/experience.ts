import { getEnumValues, PSTAT } from "contracts/enums";

export const pstatNames = {
  [PSTAT.STRENGTH]: "strength",
  [PSTAT.ARCANA]: "arcana",
  [PSTAT.DEXTERITY]: "dexterity",
} as const;

export interface PStats {
  [PSTAT.STRENGTH]: number;
  [PSTAT.ARCANA]: number;
  [PSTAT.DEXTERITY]: number;
}

export function parseArrayPStat(arrayPStat: readonly number[]): PStats {
  const [strength = 0, arcana = 0, dexterity = 0] = arrayPStat;
  return {
    [PSTAT.STRENGTH]: strength,
    [PSTAT.ARCANA]: arcana,
    [PSTAT.DEXTERITY]: dexterity,
  };
}

export function pstatsFromExperience(experience: PStats): PStats {
  return {
    [PSTAT.STRENGTH]: expToLevel(experience[PSTAT.STRENGTH]),
    [PSTAT.ARCANA]: expToLevel(experience[PSTAT.ARCANA]),
    [PSTAT.DEXTERITY]: expToLevel(experience[PSTAT.DEXTERITY]),
  };
}

// TODO this is a copy of solidity code, best find a good way to use sol code directly

const MAX_LEVEL = 16 as const;

/**
 * @dev Utility function to reverse a level into its required exp
 */
export function levelToExp(level: number) {
  if (level < 1 || level > MAX_LEVEL) {
    console.warn(`Invalid level passed to levelToExp: ${level}`);
    return 0;
  }

  // this formula starts from 0, so adjust the arg
  if (level == 1) {
    return 0;
  } else {
    level -= 1;
  }

  return 8 * (1 << level) - Math.floor(level ** 6 / 1024) + level * 200 - 120;
}

/**
 * @dev Calculate level based on single exp value
 */
export function expToLevel(expVal: number) {
  // expVal per level rises exponentially with polynomial easing
  // 1-0, 2-96, 3-312, 4-544, 5-804, 6-1121...
  for (let level = 1; level < MAX_LEVEL; level++) {
    // (1<<i) == 2**i ; can't overflow due to maxLevel
    if (expVal < levelToExp(level + 1)) {
      return level;
    }
  }
  return MAX_LEVEL;
}

/**
 * @dev Calculate aggregate exp based on weighted sum of pstat exp
 */
export function getAggregateExperience(experience: PStats, levelMul: PStats) {
  let expTotal = 0;
  let mulTotal = 0;
  for (const pstat of getEnumValues(PSTAT)) {
    expTotal += experience[pstat] * levelMul[pstat];
    mulTotal += levelMul[pstat];
  }

  return Math.floor(expTotal / mulTotal);
}
