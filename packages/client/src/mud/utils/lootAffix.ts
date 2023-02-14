import { EntityID, EntityIndex, World } from "@latticexyz/recs";

export enum AffixPartId {
  IMPLICIT,
  PREFIX,
  SUFFIX,
}

export interface LootAffix {
  partId: AffixPartId;
  protoEntity: EntityIndex;
  value: number;
}

export const parseLootAffixes = (world: World, partIds: number[], protoEntityIds: EntityID[], values: number[]) => {
  const lootAffixes: LootAffix[] = [];

  for (let i = 0; i < protoEntityIds.length; i++) {
    lootAffixes.push(parseLootAffix(world, partIds[i], protoEntityIds[i], values[i]));
  }

  return lootAffixes;
};

export const parseLootAffix = (world: World, partId: number, protoEntityId: EntityID, value: number): LootAffix => {
  const protoEntity = world.entityToIndex.get(protoEntityId);
  if (protoEntity) {
    return {
      partId: partId as AffixPartId,
      protoEntity,
      value,
    };
  } else {
    throw new Error(`statmod prototype entity index not found for entityId ${protoEntityId}`);
  }
};
