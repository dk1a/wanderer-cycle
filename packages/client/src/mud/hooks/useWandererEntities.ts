import { useEntityQuery } from "@latticexyz/react";
import { EntityID, Has, HasValue } from "@latticexyz/recs";
import { getAddress } from "ethers/lib/utils";
import { useMUD } from "../MUDContext";

export const useWandererEntities = () => {
  const {
    playerEntityId,
    components: { Wanderer, WNFT_Ownership },
  } = useMUD();

  return useEntityQuery([HasValue(WNFT_Ownership, { value: getAddress(playerEntityId) as EntityID }), Has(Wanderer)]);
};
