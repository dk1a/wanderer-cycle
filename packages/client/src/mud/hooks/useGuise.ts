import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useGuise = (entity: EntityIndex) => {
  const mud = useMUD();
  const {
    world,
    components: { GuisePrototype, GuiseSkills, Name }
  } = mud;

  const value = useComponentValue(GuisePrototype, entity);
  const skillEntityIds = useComponentValue(GuiseSkills, entity);
  const name = useComponentValue(Name, entity);

  // guises should never be deleted
  if (!value || !skillEntityIds) {
    throw new Error("Invalid guise for entity");
  }

  const skillEntities = useMemo(() => {
    return skillEntityIds.value.map((entityId) => {
      const entity = world.entityToIndex.get(entityId);
      if (!entity) {
        throw new Error(`entityId not in entityToIndex for skill ${entityId}`);
      }
      return entity;
    })
  }, [skillEntityIds]);

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
    skillEntityIds: skillEntityIds.value,
    skillEntities,
  };
};
