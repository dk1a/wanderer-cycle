import { useEntityQuery } from "@latticexyz/react";
import { Has } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useGuiseEntities = () => {
  const {
    components: { GuisePrototype },
  } = useMUD();

  return useEntityQuery(useMemo(() => [Has(GuisePrototype)], [GuisePrototype]));
};
