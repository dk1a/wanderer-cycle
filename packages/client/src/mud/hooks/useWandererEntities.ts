import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useWandererEntities = () => {
  const {
    playerEntityId,
    components: { Wanderer, WNFT_Ownership },
  } = useMUD();

  return useEntityQuery(
    useMemo(
      () => [HasValue(WNFT_Ownership, { value: playerEntityId }), Has(Wanderer)],
      [WNFT_Ownership, Wanderer, playerEntityId]
    )
  );
};
