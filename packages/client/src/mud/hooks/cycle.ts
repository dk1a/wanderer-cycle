import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../MUDContext";

export const useCompleteCycle = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems } = useMUD();

  return useCallback(async () => {
    if (wandererEntity === undefined) throw new Error("No wanderer selected");
    const tx = await systems["system.CompleteCycle"].executeTyped(world.entities[wandererEntity]);
    await tx.wait();
  }, [world, systems, wandererEntity]);
};

export const useStartCycle = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems } = useMUD();

  return useCallback(
    async (guiseProtoEntity: EntityIndex) => {
      if (wandererEntity === undefined) throw new Error("No wanderer selected");
      const tx = await systems["system.StartCycle"].executeTyped(
        world.entities[wandererEntity],
        world.entities[guiseProtoEntity]
      );
      await tx.wait();
    },
    [world, systems, wandererEntity]
  );
};
