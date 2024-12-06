import { Has } from "@latticexyz/recs";
import { useEntityQuery } from "@latticexyz/react";
import { useMUD } from "../../MUDContext";

export const useWandererEntities = () => {
  const {
    components: { Wanderer },
  } = useMUD();

  return useEntityQuery([Has(Wanderer)]);
};
