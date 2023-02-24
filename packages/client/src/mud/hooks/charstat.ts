import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { PStats, pstatsFromExperience } from "../utils/experience";
import { useGetValuesFinal } from "./statmod";
import { useExperience } from "./useExperience";

export function usePstat(targetEntity: EntityIndex | undefined, key: keyof PStats) {
  // some entities (players) have experience
  const experience = useExperience(targetEntity);
  // others may have a directly-set level
  const directLevel = useGetValuesFinal(targetEntity, "level", 0);

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
    base: pstatBase,
    buffed: pstatBase + pstat,
    experience,
  };
}

// TODO this duplicates LibCharstat.sol
export const useLife = (targetEntity: EntityIndex | undefined) => {
  const strength = usePstat(targetEntity, "strength");

  const baseValue = 2 + 2 * strength.buffed;
  return useGetValuesFinal(targetEntity, "life", baseValue);
};

export const useMana = (targetEntity: EntityIndex | undefined) => {
  const arcana = usePstat(targetEntity, "arcana");

  const baseValue = 4 * arcana.buffed;
  return useGetValuesFinal(targetEntity, "mana", baseValue);
};
