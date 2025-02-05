import { useComponentValue } from "@latticexyz/react";
import { Entity } from "@latticexyz/recs";
import { useMUD } from "../../MUDContext";

type ExperienceType = {
  strength: number;
  arcana: number;
  dexterity: number;
};

export const useExperience = (entity: Entity | undefined) => {
  const {
    components: { Experience },
  } = useMUD();

  const experience = useComponentValue(Experience, entity) as
    | ExperienceType
    | undefined;
  if (!experience) return;
  console.log(experience);

  return {
    strength: experience.strength,
    arcana: experience.arcana,
    dexterity: experience.dexterity,
  };
};
