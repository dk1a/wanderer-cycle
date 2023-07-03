import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../MUDContext";
import { toastPromise } from "../utils/toast";

export const useWandererSpawn = () => {
  const { world, systems } = useMUD();

  return useCallback(
    async (guiseProtoEntity: EntityIndex) => {
      const tx = await systems["system.WandererSpawn"].executeTyped(world.entities[guiseProtoEntity]);
      await toastPromise(tx.wait(), `Generate Wanderer..`, `Wanderer generated`);
    },
    [world, systems]
  );
};
