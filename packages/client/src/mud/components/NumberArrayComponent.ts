import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

const NumberArray = {
  value: Type.NumberArray,
} as const;

export function defineNumberArrayComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<typeof NumberArray, M>(world, NumberArray, options);
}
