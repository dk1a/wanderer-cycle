import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useBossesDefeated = (entity: EntityIndex | undefined) => {
  const {
    world,
    components: { CycleBossesDefeated },
  } = useMUD();

  const cycleBossesDefeated = useComponentValue(CycleBossesDefeated, entity);
  return useMemo(() => {
    const entityIds = cycleBossesDefeated?.value ?? [];
    return entityIds
      .map((entityId) => {
        return world.entityToIndex.get(entityId);
      })
      .filter((entity) => entity !== undefined) as EntityIndex[];
  }, [world, cycleBossesDefeated]);
};
