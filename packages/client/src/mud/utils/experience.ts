export const pstatNames = ["strength", "arcana", "dexterity"] as const;

export interface PStats {
  strength: number;
  arcana: number;
  dexterity: number;
}

export function parseArrayPStat(arrayPStat: readonly number[]): PStats {
  const [strength = 0, arcana = 0, dexterity = 0] = arrayPStat;
  return {
    strength,
    arcana,
    dexterity,
  };
}

export const pstatsFromExperience = (experience: PStats) => {
  return {
    strength: expToLevel(experience.strength),
    arcana: expToLevel(experience.arcana),
    dexterity: expToLevel(experience.dexterity),
  };
};

// TODO this is a copy of solidity code, best find a good way to use sol code directly

const MAX_LEVEL = 16 as const;

/**
 * @dev Utility function to reverse a level into its required exp
 */
export const levelToExp = (level: number) => {
  if (level < 1 || level > MAX_LEVEL) throw new Error("Invalid level");

  // this formula starts from 0, so adjust the arg
  if (level == 1) {
    return 0;
  } else {
    level -= 1;
  }

  return 8 * (1 << level) - Math.floor(level ** 6 / 1024) + level * 200 - 120;
};

/**
 * @dev Calculate level based on single exp value
 */
export const expToLevel = (expVal: number) => {
  // expVal per level rises exponentially with polynomial easing
  // 1-0, 2-96, 3-312, 4-544, 5-804, 6-1121...
  for (let level = 1; level < MAX_LEVEL; level++) {
    // (1<<i) == 2**i ; can't overflow due to maxLevel
    if (expVal < levelToExp(level + 1)) {
      return level;
    }
  }
  return MAX_LEVEL;
};

/**
 * @dev Calculate aggregate exp based on weighted sum of pstat exp
 */
export const getAggregateExperience = (
  experience: PStats,
  levelMul: PStats,
) => {
  let expTotal = 0;
  let mulTotal = 0;
  for (const pstatName of pstatNames) {
    expTotal += experience[pstatName] * levelMul[pstatName];
    mulTotal += levelMul[pstatName];
  }

  return Math.floor(expTotal / mulTotal);
};
