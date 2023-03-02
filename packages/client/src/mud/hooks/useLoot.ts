import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getLoot } from "../utils/getLoot";

export const useLoot = (entity: EntityIndex) => {
  const { world, components } = useMUD();

  return useMemo(() => {
    return getLoot(world, components, entity);
  }, [world, components, entity]);
};
