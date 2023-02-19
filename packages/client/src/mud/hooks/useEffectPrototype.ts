import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getEffectPrototype } from "../utils/getEffect";

export const useEffectPrototype = (entity: EntityIndex) => {
  const {
    world,
    components: { EffectPrototype },
  } = useMUD();

  return useMemo(() => {
    return getEffectPrototype(world, EffectPrototype, entity);
  }, [world, EffectPrototype, entity]);
};
