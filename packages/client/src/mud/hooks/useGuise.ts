import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useGuise = (entity: EntityIndex) => {
  const mud = useMUD();
  const {
    world,
    components: { GuisePrototype, GuiseSkills, Name }
  } = mud;

  const value = useComponentValue(GuisePrototype, entity);
  const skillEntities = useComponentValue(GuiseSkills, entity);
  const name = useComponentValue(Name, entity);

  // guises should never be deleted
  if (!value || !skillEntities) {
    throw new Error("Invalid guise for entity");
  }

  return {
    entity,
    entityId: world.entities[entity],
    name: name ?? '',

    gainMul: {
      strength: value.gainMul_strength,
      arcana: value.gainMul_arcana,
      dexterity: value.gainMul_dexterity,
    },
    levelMul: {
      strength: value.levelMul_strength,
      arcana: value.levelMul_arcana,
      dexterity: value.levelMul_dexterity,
    },
    skillEntities,
  };
};
