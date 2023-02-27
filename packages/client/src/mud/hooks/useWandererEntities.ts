import { useEntityQuery } from "@latticexyz/react";
import { Has, HasValue } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useWandererEntities = () => {
  const {
    playerEntityId,
    components: { Wanderer, WNFT_Ownership },
  } = useMUD();

  return useEntityQuery([HasValue(WNFT_Ownership, { value: playerEntityId }), Has(Wanderer)]);
};
