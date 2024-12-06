import { useCallback } from "react";
import { Entity } from "@latticexyz/recs";
import { useMUD } from "../../MUDContext";

export const useSpawnWanderer = () => {
  const { systemCalls } = useMUD();

  return useCallback(
    async (guiseEntity: Entity) => {
      await systemCalls.spawnWanderer(guiseEntity);
    },
    [systemCalls],
  );
};
