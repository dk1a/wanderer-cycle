import { Entity } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../../MUDContext";

export const useAppliedEffects = (targetEntity: Entity | undefined) => {
  const {
    network: { tables, useStore },
  } = useMUD();

  // TODO
  const rec = useStore((state) => state.getRecords(tables.EffectApplied));

  return useMemo(() => {
    if (!targetEntity) return [];

    console.log("asd", rec);

    /*
    return filteredEntities.map(({ protoEntity, appliedEntity }) =>
      getAppliedEffect(world, components, appliedEntity, protoEntity),
    );
    */
  }, [rec, targetEntity]);
};
