import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useGuise } from "./useGuise";

export const useActiveGuise = (targetEntity: EntityIndex) => {
  const mud = useMUD();
  const {
    world,
    components: { ActiveGuise },
  } = mud;

  const activeGuise = useComponentValue(ActiveGuise, targetEntity);
  const guiseEntity = useMemo(() => {
    const guiseEntityId = activeGuise?.value;
    if (!guiseEntityId) return;
    return world.entityToIndex.get(guiseEntityId);
  }, [world, activeGuise]);

  if (guiseEntity === undefined) {
    throw new Error(`No active guise for target entity ${targetEntity}`);
  }

  return useGuise(guiseEntity);
};
