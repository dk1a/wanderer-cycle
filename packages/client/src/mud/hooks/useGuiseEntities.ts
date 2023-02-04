import { Has } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useGuiseEntities = () => {
  const {
    components: { GuisePrototype }
  } = useMUD();

  return useEntityQuery(
    useMemo(
      () => [Has(GuisePrototype)],
      [GuisePrototype]
    )
  );
};
