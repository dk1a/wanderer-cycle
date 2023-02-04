import { Has } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useGuiseEntities = () => {
  const mud = useMUD();
  const {
    components: { GuisePrototype }
  } = mud;

  return useEntityQuery(
    useMemo(
      () => [Has(GuisePrototype)],
      [GuisePrototype]
    )
  );
};
