import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useGuise = (entity: EntityIndex | undefined) => {
  const mud = useMUD();
  const {
    world,
    components: { GuisePrototype, GuiseSkills, Name },
  } = mud;

  const guisePrototype = useComponentValue(GuisePrototype, entity);
  const skillEntityIds = useComponentValue(GuiseSkills, entity);
  const name = useComponentValue(Name, entity);

  const skillEntities = useMemo(() => {
    return skillEntityIds?.value.map((entityId) => {
      const entity = world.entityToIndex.get(entityId);
      if (!entity) {
        throw new Error(`entityId not in entityToIndex for skill ${entityId}`);
      }
      return entity;
    });
  }, [skillEntityIds, world]);

  if (entity === undefined || !guisePrototype) {
    return;
  }
  if (!skillEntityIds || !skillEntities) {
    throw new Error(`Invalid guise without skills ${entity}`);
  }

  return {
    entity,
    entityId: world.entities[entity],
    name: name?.value ?? "",

    gainMul: {
      strength: guisePrototype.gainMul_strength,
      arcana: guisePrototype.gainMul_arcana,
      dexterity: guisePrototype.gainMul_dexterity,
    },
    levelMul: {
      strength: guisePrototype.levelMul_strength,
      arcana: guisePrototype.levelMul_arcana,
      dexterity: guisePrototype.levelMul_dexterity,
    },
    skillEntityIds: skillEntityIds.value,
    skillEntities,
  };
};
