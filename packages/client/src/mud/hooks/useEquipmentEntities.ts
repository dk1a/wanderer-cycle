import { Has, HasValue } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useEquipmentEntities = () => {
  const {
    playerEntityId,
    components: { WNFT_Ownership, EquipmentPrototype },
  } = useMUD();

  return useEntityQuery(
    useMemo(
      () => [HasValue(WNFT_Ownership, { value: playerEntityId }), Has(EquipmentPrototype)],
      [WNFT_Ownership, EquipmentPrototype, playerEntityId]
    )
  );
};
