import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../MUDContext";

export const useWandererSpawn = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (guiseProtoEntity: EntityIndex) => {
      const tx = await systems["system.WandererSpawn"].executeTyped(world.entities[guiseProtoEntity]);
      await tx.wait();
    },
    [world, systems]
  );
};
