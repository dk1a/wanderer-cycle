import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useExperience = (entity: EntityIndex | undefined) => {
  const {
    components: { Experience },
  } = useMUD();

  const experience = useComponentValue(Experience, entity);
  if (!experience) return;

  return {
    strength: experience.strength,
    arcana: experience.arcana,
    dexterity: experience.dexterity,
  };
};
