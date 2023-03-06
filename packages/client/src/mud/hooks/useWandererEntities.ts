import { EntityID, Has, HasValue } from "@latticexyz/recs";
import { getAddress } from "ethers/lib/utils";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useWandererEntities = () => {
  const {
    playerEntityId,
    components: { Wanderer, WNFT_Ownership },
  } = useMUD();

  return useEntityQuery(
    [HasValue(WNFT_Ownership, { value: getAddress(playerEntityId) as EntityID }), Has(Wanderer)],
    true
  );
};
