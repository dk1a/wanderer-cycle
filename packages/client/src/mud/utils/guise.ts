import { EntityIndex, getComponentValueStrict } from "@latticexyz/recs";
import { SetupResult } from "../setup";

export type GuiseData = ReturnType<typeof getGuise>;

export const getGuise = (
  { world, components: { GuisePrototype, GuiseSkills, Name } }: SetupResult,
  entity: EntityIndex
) => {
  const guisePrototype = getComponentValueStrict(GuisePrototype, entity);
  const skillEntityIds = getComponentValueStrict(GuiseSkills, entity);
  const name = getComponentValueStrict(Name, entity);

  const skillEntities = skillEntityIds?.value.map((entityId) => {
    const entity = world.entityToIndex.get(entityId);
    if (!entity) {
      throw new Error(`entityId not in entityToIndex for skill ${entityId}`);
    }
    return entity;
  });

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
