import { getComponentValueStrict, Has } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useGuiseList = () => {
  const {
    world,
    components: { GuisePrototype },
  } = useMUD();

  return useEntityQuery(
    useMemo(
      () => [Has(GuisePrototype)],
      [GuisePrototype]
    )
  ).map((entity) => {
    const value = getComponentValueStrict(GuisePrototype, entity);
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
    };
  });
};
