import { EntityID, EntityIndex } from "@latticexyz/recs";
import { useCallback, useEffect } from "react";
import { useMUD } from "../MUDContext";
import { toastCalling } from "../utils/toast";

export const useCompleteCycle = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems } = useMUD();

  return useCallback(async () => {
    if (wandererEntity === undefined) throw new Error("No wanderer selected");
    const tx = await systems["system.CompleteCycle"].executeTyped(world.entities[wandererEntity], {
      gasLimit: 5000000,
    });
    await toastCalling(tx.wait(), `Cycle complete... `, `Cycle completed! `);
  }, [world, systems, wandererEntity]);
};

export const useStartCycle = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems } = useMUD();

  return useCallback(
    async (guiseProtoEntity: EntityIndex, wheelEntity: EntityIndex) => {
      if (wandererEntity === undefined) throw new Error("No wanderer selected");
      const tx = await systems["system.StartCycle"].executeTyped(
        world.entities[wandererEntity],
        world.entities[guiseProtoEntity],
        world.entities[wheelEntity],
        { gasLimit: 30000000 }
      );
      await toastCalling(tx.wait(), `Starts cycle... `, `Cycle started!`);
    },
    [world, systems, wandererEntity]
  );
};

export interface OnCompleteCycleData {
  identity: number;
}

/**
 * Calls the callback after each CycleCombat system call with combat results as arguments
 */
export function useOnCompleteCycleEffect(
  selectedWandererEntity: EntityIndex | undefined,
  callback: (combatData: OnCompleteCycleData) => void
) {
  const {
    world,
    systemCallStreams,
    components: { Identity },
  } = useMUD();

  useEffect(() => {
    const subscription = systemCallStreams["system.CompleteCycle"].subscribe((systemCall) => {
      const { wandererEntity: wandererEntityId, guiseProtoEntity: guiseProtoEntityId } = systemCall.args as {
        wandererEntity: EntityID;
        guiseProtoEntity: EntityID;
      };
      // filter for the selected wanderer
      if (selectedWandererEntity !== world.entityToIndex.get(wandererEntityId)) return;

      const identityUpdate = systemCall.updates.find(({ component }) => component.id === Identity.id);
      const identity = identityUpdate?.value?.value as number;

      callback({
        identity,
      });
    });
    return () => subscription.unsubscribe();
  }, [world, Identity, systemCallStreams, callback, selectedWandererEntity]);
}
