import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

const Effect = {
  removability: Type.Number,
  statmodProtoEntities: Type.EntityArray,
  statmodValues: Type.NumberArray,
} as const;

export function defineEffectComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<typeof Effect, M>(world, Effect, options);
}
