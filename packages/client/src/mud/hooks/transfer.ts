import { EntityIndex } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";

export default function useTransferFrom() {
  const { world, systems, playerEntityId } = useMUD();

  return useCallback(
    async (toPlayerEntity: EntityIndex, tokenId: string) => {
      const tx = await systems["system.WNFT"].transferFrom(playerEntityId, world.entities[toPlayerEntity], tokenId);
      await tx.wait();
    },
    [world, systems]
  );
}
