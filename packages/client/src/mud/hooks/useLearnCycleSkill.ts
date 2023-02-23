import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../MUDContext";

export const useLearnCycleSkill = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems } = useMUD();

  return useCallback(
    async (skillEntity: EntityIndex) => {
      if (wandererEntity === undefined) throw new Error("No wanderer selected");
      const tx = await systems["system.LearnCycleSkill"].executeTyped(
        world.entities[wandererEntity],
        world.entities[skillEntity]
      );
      await tx.wait();
    },
    [world, systems, wandererEntity]
  );
};
