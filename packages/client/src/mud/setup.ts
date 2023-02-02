import { setupMUDNetwork } from "@latticexyz/std-client";
import type { SystemTypes } from "contracts/types/SystemTypes";
import { config } from "./config";
import { components, clientComponents } from "./components";
import { world } from "./world";
import { SystemAbis } from "contracts/types/SystemAbis.mjs";
import { overridableComponent, type EntityID } from "@latticexyz/recs";
import { GodID as singletonEntityId } from "@latticexyz/network";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export const setup = async () => {
  const result = await setupMUDNetwork<typeof components, SystemTypes>(
    config,
    world,
    components,
    SystemAbis,
    {
      fetchSystemCalls: true,
    }
  );
  // TODO fix network sync
  //result.startSync();

  // For LoadingState updates
  const singletonEntity = world.registerEntity({ id: singletonEntityId });

  // Register player entity
  const address = result.network.connectedAddress.get();
  if (!address) throw new Error("Not connected");

  const playerEntityId = address as EntityID;
  const playerEntity = world.registerEntity({ id: playerEntityId });

  // Add support for optimistic rendering
  const componentsWithOverrides = {
    // TODO loading state override is a crutch while network sync doesn't work
    LoadingState: overridableComponent(result.components.LoadingState),
  };

  return {
    ...result,
    world,
    singletonEntityId,
    singletonEntity,
    playerEntityId,
    playerEntity,
    components: {
      ...result.components,
      ...componentsWithOverrides,
      ...clientComponents,
    },
  };
};
