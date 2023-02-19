import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getLoot } from "../utils/getLoot";

export const useLoot = (entity: EntityIndex) => {
  const {
    world,
    components: { Loot, FromPrototype, EffectPrototype, AffixNaming },
  } = useMUD();

  return useMemo(() => {
    return getLoot(world, { Loot, FromPrototype, EffectPrototype, AffixNaming }, entity);
  }, [world, Loot, FromPrototype, EffectPrototype, AffixNaming, entity]);
};
