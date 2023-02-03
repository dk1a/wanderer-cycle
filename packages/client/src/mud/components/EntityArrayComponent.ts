import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

const EntityArray = {
  value: Type.EntityArray,
} as const;

export function defineEntityArrayComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<typeof EntityArray, M>(world, EntityArray, options);
}
