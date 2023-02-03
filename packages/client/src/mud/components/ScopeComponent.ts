import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

const Scope = {
  scope: Type.String,
} as const;

export function defineScopeComponent<M extends Metadata>(
  world: World,
  options?: { id?: string; metadata?: M; indexed?: boolean }
) {
  return defineComponent<typeof Scope, M>(world, Scope, options);
}
