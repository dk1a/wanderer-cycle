import { Entity, getComponentValueStrict } from "@latticexyz/recs";
import { ClientComponents } from "../createClientComponents";

export type GuiseData = ReturnType<typeof getGuise>;

export const getGuise = (components: ClientComponents, entity: Entity) => {
  const guisePrototype = getComponentValueStrict(
    components.GuisePrototype,
    entity,
  );
  const skillEntities = getComponentValueStrict(components.GuiseSkills, entity)
    .entityArray as Entity[];
  const name = getComponentValueStrict(components.GuiseName, entity);

  const affixPart = Array.isArray(guisePrototype.affixPart)
    ? guisePrototype.affixPart
    : [];
  const [arcana = 0, dexterity = 0, strength = 0] = affixPart;

  return {
    entity,
    name: name?.name ?? "",

    levelMul: {
      arcana,
      dexterity,
      strength,
    },

    skillEntities,
  };
};
