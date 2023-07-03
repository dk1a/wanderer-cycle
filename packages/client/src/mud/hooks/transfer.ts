import { EntityID } from "@latticexyz/recs";
import { useCallback } from "react";
import { useMUD } from "../../mud/MUDContext";
import { toastPromise } from "../utils/toast";

export default function useTransferFrom() {
  const { systems, playerEntityId } = useMUD();

  return useCallback(
    async (toPlayerEntityId: string, tokenId: EntityID) => {
      const tx = await systems["system.WNFT"].transferFrom(playerEntityId, toPlayerEntityId, tokenId);
      await toastPromise(
        tx.wait(),
        `Transfer for ${toPlayerEntityId}..`,
        `The transfer for ${toPlayerEntityId} is completed`
      );
    },
    [systems, playerEntityId]
  );
}
