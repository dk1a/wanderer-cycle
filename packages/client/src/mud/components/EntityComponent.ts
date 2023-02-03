import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

const Entity = {
  value: Type.Entity,
} as const;

export function defineEntityComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<typeof Entity, M>(world, Entity, options);
}
