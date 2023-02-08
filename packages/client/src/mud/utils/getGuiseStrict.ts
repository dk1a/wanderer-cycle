import { EntityIndex, getComponentValueStrict } from "@latticexyz/recs";
import { SetupResult } from "../setup";

export const getGuiseStrict = (
  { world, components: { GuisePrototype, GuiseSkills } }: SetupResult,
  entity: EntityIndex
) => {
  const value = getComponentValueStrict(GuisePrototype, entity);
  const skillEntities = getComponentValueStrict(GuiseSkills, entity);
  return {
    entity,
    entityId: world.entities[entity],
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
