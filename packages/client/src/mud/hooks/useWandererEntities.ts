import { Has, HasValue } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useWandererEntities = () => {
  const {
    playerEntityId,
    components: { Wanderer, WNFT_Ownership },
  } = useMUD();

  return useEntityQuery(
    useMemo(
      // TODO fix ownership query
      () => [/*HasValue(WNFT_Ownership, { value: playerEntityId }), */ Has(Wanderer)],
      [Wanderer]
    )
  );
};
