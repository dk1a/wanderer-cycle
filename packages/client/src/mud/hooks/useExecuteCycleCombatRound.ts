import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../MUDContext";
import { CombatAction } from "../utils/combat";

export const useExecuteCycleCombatRound = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (wandererEntity: EntityIndex, actions: CombatAction[]) => {
      const tx = await systems["system.CycleCombat"].executeTyped(world.entities[wandererEntity], actions);
      await tx.wait();
    },
    [world, systems]
  );
};
