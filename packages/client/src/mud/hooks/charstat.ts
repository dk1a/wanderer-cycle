import { useMemo } from "react";
import {
  Elemental,
  parseElemental,
  StatmodElement,
  statmodElements,
} from "../utils/elemental";
import {
  expToLevel,
  getAggregateExperience,
  pstatNames,
  PStats,
  pstatsFromExperience,
} from "../utils/experience";
//import { useGetValuesElementalFinal, useGetValuesFinal } from "./statmod";
import { useExperience } from "./useExperience";

import { StatmodTopic, ElementalStatmodTopic } from "../utils/topics";
import { Hex } from "viem";

// TODO replace placeholders
const useGetValuesFinal = (
  targetEntity: Hex | undefined,
  topic: StatmodTopic,
  baseValue: number,
) => {
  return baseValue;
};

// TODO replace placeholders
const useGetValuesElementalFinal = (
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  targetEntity: Hex | undefined,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  topic: ElementalStatmodTopic,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  baseValues: Elemental,
) => {
  return 10;
};

export type PStatData = ReturnType<typeof usePstat>;
export type LevelData = ReturnType<typeof useLevel>;

export function usePstats(targetEntity: Hex | undefined) {
  const pstats = [];
  for (const pstatName of pstatNames) {
    // eslint-disable-next-line react-hooks/rules-of-hooks -- pstatNames can never change, so it's safe to loop
    pstats.push(usePstat(targetEntity, pstatName));
  }
  return pstats;
}

export function usePstat(targetEntity: Hex | undefined, key: keyof PStats) {
  const { experience, directLevel } = useExperienceAndDirectLevel(targetEntity);

  const pstatBase = useMemo(() => {
    if (experience !== undefined) {
      return pstatsFromExperience(experience)[key];
    } else {
      return directLevel;
    }
  }, [experience, key, directLevel]);

  // either entity can in addition have statmods affect a specific pstat
  const pstat = useGetValuesFinal(targetEntity, key, 0);
  return {
    name: key,
    baseLevel: pstatBase,
    buffedLevel: pstatBase + pstat,
    experience: experience?.[key],
  };
}

export function useLevel(
  targetEntity: Hex | undefined,
  levelMul: PStats | undefined,
) {
  const { experience, directLevel } = useExperienceAndDirectLevel(targetEntity);

  if (experience && levelMul) {
    const aggregateExperience = getAggregateExperience(experience, levelMul);
    return {
      level: expToLevel(aggregateExperience),
      experience: aggregateExperience,
    };
  } else if (directLevel) {
    return {
      level: directLevel,
      experience: undefined,
    };
  } else {
    return undefined;
  }
}

function useExperienceAndDirectLevel(targetEntity: Hex | undefined) {
  // some entities (players) have experience
  const experience = useExperience(targetEntity);
  // others may have a directly-set level
  const directLevel = useGetValuesFinal(targetEntity, "level", 0);
  return { experience, directLevel };
}

// TODO this duplicates LibCharstat.sol
export const useLife = (targetEntity: Hex | undefined) => {
  const strength = usePstat(targetEntity, "strength");

  const baseValue = useMemo(() => 2 + 2 * strength.buffedLevel, [strength]);
  return useGetValuesFinal(targetEntity, "life", baseValue);
};

export const useMana = (targetEntity: Hex | undefined) => {
  const arcana = usePstat(targetEntity, "arcana");

  const baseValue = useMemo(() => 4 * arcana.buffedLevel, [arcana]);
  return useGetValuesFinal(targetEntity, "mana", baseValue);
};

export const useAttack = (targetEntity: Hex | undefined) => {
  const strength = usePstat(targetEntity, "strength");
  // strength increases physical base attack damage
  const baseValues = useMemo(
    () => parseElemental(0, Math.floor(strength.buffedLevel / 2) + 1, 0, 0, 0),
    [strength],
  );

  return useGetValuesElementalFinal(targetEntity, "attack", baseValues);
};

export const useResistance = (targetEntity: Hex | undefined) => {
  const dexterity = usePstat(targetEntity, "dexterity");
  const baseValues = useMemo(
    () => parseElemental(Math.floor(dexterity.buffedLevel / 4) * 4, 0, 0, 0, 0),
    [dexterity],
  );

  return useGetValuesElementalFinal(targetEntity, "resistance", baseValues);
};

export const useSpell = (
  targetEntity: Hex | undefined,
  baseValues: Elemental,
) => {
  const arcana = usePstat(targetEntity, "arcana");
  const buffedBaseValues = useMemo(() => {
    const buffedBaseValues = { ...baseValues };
    for (const element of statmodElements) {
      if (element !== StatmodElement.NONE) {
        buffedBaseValues[element] += arcana.buffedLevel;
      }
    }
    return buffedBaseValues;
  }, [baseValues, arcana]);

  return useGetValuesElementalFinal(targetEntity, "spell", buffedBaseValues);
};
