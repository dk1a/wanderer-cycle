import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../MUDContext";

export const useActivateCycleCombat = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (wandererEntity: EntityIndex, mapEntity: EntityIndex) => {
      const tx = await systems["system.CycleActivateCombat"].executeTyped(
        world.entities[wandererEntity],
        world.entities[mapEntity]
      );
      await tx.wait();
    },
    [world, systems]
  );
};
