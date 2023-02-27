import { useEntityQuery } from "@latticexyz/react";
import { Has } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useGuiseEntities = () => {
  const {
    components: { GuisePrototype },
  } = useMUD();

  return useEntityQuery([Has(GuisePrototype)]);
};
