import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { expToLevel, getAggregateExperience, pstatNames, PStats, pstatsFromExperience } from "../utils/experience";
import { useGetValuesFinal } from "./statmod";
import { useExperience } from "./useExperience";

export type PStatData = ReturnType<typeof usePstat>;
export type LevelData = ReturnType<typeof useLevel>;

export function usePstats(targetEntity: EntityIndex | undefined) {
  const pstats = [];
  for (const pstatName of pstatNames) {
    // eslint-disable-next-line react-hooks/rules-of-hooks -- pstatNames can never change, so it's safe to loop
    pstats.push(usePstat(targetEntity, pstatName));
  }
  return pstats;
}

export function usePstat(targetEntity: EntityIndex | undefined, key: keyof PStats) {
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

export function useLevel(targetEntity: EntityIndex | undefined, levelMul: PStats | undefined) {
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

function useExperienceAndDirectLevel(targetEntity: EntityIndex | undefined) {
  // some entities (players) have experience
  const experience = useExperience(targetEntity);
  // others may have a directly-set level
  const directLevel = useGetValuesFinal(targetEntity, "level", 0);
  return { experience, directLevel };
}

// TODO this duplicates LibCharstat.sol
export const useLife = (targetEntity: EntityIndex | undefined) => {
  const strength = usePstat(targetEntity, "strength");

  const baseValue = 2 + 2 * strength.buffedLevel;
  return useGetValuesFinal(targetEntity, "life", baseValue);
};

export const useMana = (targetEntity: EntityIndex | undefined) => {
  const arcana = usePstat(targetEntity, "arcana");

  const baseValue = 4 * arcana.buffedLevel;
  return useGetValuesFinal(targetEntity, "mana", baseValue);
};
