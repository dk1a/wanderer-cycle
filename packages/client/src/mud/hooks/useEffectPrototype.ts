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

export type EffectPrototype = NonNullable<ReturnType<typeof useEffectPrototype>>;
export type AppliedEffect = NonNullable<ReturnType<typeof useAppliedEffect>>;

const useEffectPrototypeGeneric = (component: ReturnType<typeof defineEffectComponent>, entity: EntityIndex) => {
  const { world } = useMUD();

  const effectPrototype = useComponentValue(component, entity);

  const statmods = useMemo(() => {
    if (!effectPrototype) return;
    return parseEffectStatmods(world, effectPrototype.statmodProtoEntities, effectPrototype.statmodValues);
  }, [world, effectPrototype]);

  if (!entity || !effectPrototype) return;

  return {
    entity,
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
    world,
    components: { AppliedEffect, FromPrototype, SkillPrototype, WNFT_Ownership },
  } = useMUD();

  const effectPrototypeData = useEffectPrototypeGeneric(AppliedEffect, entity);

  const fromPrototype = useComponentValue(FromPrototype, entity);
  const protoEntity = useMemo(() => {
    if (!fromPrototype) return;
    return world.entityToIndex.get(fromPrototype.value);
  }, [world, fromPrototype]);

  const skillProto = useComponentValue(SkillPrototype, protoEntity);
  const itemProto = useComponentValue(WNFT_Ownership, protoEntity);

  if (!effectPrototypeData) return;

  return {
    ...effectPrototypeData,
    protoEntity,

    isSkill: skillProto !== undefined,
    isItem: itemProto !== undefined,
  };
};
