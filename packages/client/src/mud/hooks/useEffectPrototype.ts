import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { defineEffectComponent } from "../components/EffectComponent";
import { useMUD } from "../MUDContext";
import { parseEffectStatmods } from "../utils/effectStatmod";

export enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT,
}

const useEffectPrototypeGeneric = (component: ReturnType<typeof defineEffectComponent>, entity: EntityIndex) => {
  const { world } = useMUD();

  const effectPrototype = useComponentValue(component, entity);

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

export const useEffectPrototype = (entity: EntityIndex) => {
  const {
    components: { EffectPrototype },
  } = useMUD();

  return useEffectPrototypeGeneric(EffectPrototype, entity);
};

export const useAppliedEffect = (entity: EntityIndex) => {
  const {
    components: { AppliedEffect },
  } = useMUD();

  return useEffectPrototypeGeneric(AppliedEffect, entity);
};
