import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { parseEffectStatmods } from "../utils/effectStatmod";

export enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT,
}

export const useEffectPrototype = (entity: EntityIndex) => {
  const {
    world,
    components: { EffectPrototype },
  } = useMUD();

  const effectPrototype = useComponentValue(EffectPrototype, entity);

  const statmods = useMemo(() => {
    if (!effectPrototype) return;
    return parseEffectStatmods(world, effectPrototype.statmodProtoEntities, effectPrototype.statmodValues);
  }, [world, effectPrototype]);

  if (!effectPrototype) return;

  return {
    removability: effectPrototype.removability as EffectRemovability,
    statmods,
  };
};
