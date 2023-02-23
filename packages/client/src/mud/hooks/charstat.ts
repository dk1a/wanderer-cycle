import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { PStats, pstatsFromExperience } from "../utils/experience";
import { useGetValuesFinal } from "./statmod";
import { useExperience } from "./useExperience";

// TODO account for entities without experience
function usePstat(targetEntity: EntityIndex | undefined, key: keyof PStats) {
  const experience = useExperience(targetEntity);
  return useMemo(() => {
    if (!experience) return 0;
    return pstatsFromExperience(experience)[key];
  }, [experience, key]);
}

// TODO this duplicates LibCharstat.sol
export const useLife = (targetEntity: EntityIndex | undefined) => {
  const strength = usePstat(targetEntity, "strength");

  const baseValue = 2 + 2 * strength;
  return useGetValuesFinal(targetEntity, "life", baseValue);
};

export const useMana = (targetEntity: EntityIndex | undefined) => {
  const arcana = usePstat(targetEntity, "arcana");

  const baseValue = 4 * arcana;
  return useGetValuesFinal(targetEntity, "mana", baseValue);
};
