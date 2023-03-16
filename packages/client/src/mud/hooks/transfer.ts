import { EntityID } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";

export default function useTransferFrom() {
  const { world, systems, playerEntityId } = useMUD();

  return useCallback(
    async (toPlayerEntityId: EntityID, tokenId: EntityID | string) => {
      const tx = await systems["system.WNFT"].transferFrom(playerEntityId, toPlayerEntityId, tokenId);
      await tx.wait();
    },
    [world, systems]
  );
}
