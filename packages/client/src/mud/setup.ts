import { setupMUDNetwork } from "@latticexyz/std-client";
import type { SystemTypes } from "contracts/types/SystemTypes";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import type { EntityID } from "@latticexyz/recs";
import { SingletonID } from "@latticexyz/network";
import { config } from "./config";
import { components, clientComponents } from "./components";
import { world } from "./world";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export const setup = async () => {
  const result = await setupMUDNetwork<typeof components, SystemTypes>(config, world, components, SystemAbis, {
    fetchSystemCalls: true,
  });
  result.startSync();

  // For LoadingState updates
  const SingletonEntity = world.registerEntity({ id: SingletonID });

  // Register player entity
  const address = result.network.connectedAddress.get();
  if (!address) throw new Error("Not connected");

  const playerEntityId = address as EntityID;
  const playerEntity = world.registerEntity({ id: playerEntityId });

  // Add support for optimistic rendering
  const componentsWithOverrides = {};

  return {
    ...result,
    world,
    SingletonID,
    SingletonEntity,
    playerEntityId,
    playerEntity,
    components: {
      ...result.components,
      ...componentsWithOverrides,
      ...clientComponents,
    },
  };
};
