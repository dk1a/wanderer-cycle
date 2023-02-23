import { EntityID, EntityIndex, World } from "@latticexyz/recs";

export interface EffectStatmodData {
  protoEntity: EntityIndex;
  value: number;
}

export const parseEffectStatmods = (world: World, protoEntityIds: EntityID[], values: number[]) => {
  const effectStatmods: EffectStatmodData[] = [];

  for (let i = 0; i < protoEntityIds.length; i++) {
    effectStatmods.push(parseEffectStatmod(world, protoEntityIds[i], values[i]));
  }

  return effectStatmods;
};

export const parseEffectStatmod = (world: World, protoEntityId: EntityID, value: number) => {
  const protoEntity = world.entityToIndex.get(protoEntityId);
  if (protoEntity) {
    return {
      protoEntity,
      value,
    };
  } else {
    throw new Error(`statmod prototype entity index not found for entityId ${protoEntityId}`);
  }
};
