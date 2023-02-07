import { useComponentValue } from "@latticexyz/react";
import { EntityID, EntityIndex, World } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

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

export interface EffectStatmod {
  protoEntity: EntityIndex;
  value: number;
}

const parseEffectStatmods = (world: World, protoEntityIds: EntityID[], values: number[]) => {
  const effectStatmods: EffectStatmod[] = [];

  for (let i = 0; i < protoEntityIds.length; i++) {
    const protoEntityId = protoEntityIds[i];
    const value = values[i];

    const protoEntity = world.entityToIndex.get(protoEntityId);
    if (protoEntity) {
      effectStatmods.push({
        protoEntity,
        value,
      });
    } else {
      throw new Error(`statmod prototype entity index not found for entityId ${protoEntityId}`);
    }
  }

  return effectStatmods;
};
