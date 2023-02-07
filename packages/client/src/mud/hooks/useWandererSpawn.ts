import { useCallback } from "react";
import { useMUD } from "../MUDContext";

export const useWandererSpawn = () => {
  const { systems } = useMUD();

  return useCallback(
    async (guiseProtoEntity: string) => {
      const tx = await systems["system.WandererSpawn"].executeTyped(guiseProtoEntity);
      await tx.wait();
    },
    [systems]
  );
};
