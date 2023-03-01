import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { EntityIndex, Has } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getGuise } from "../utils/guise";

export const useGuise = (entity: EntityIndex | undefined) => {
  const mud = useMUD();

  return useMemo(() => {
    if (entity === undefined) return;
    return getGuise(mud, entity);
  }, [mud, entity]);
};

export const useGuises = () => {
  const mud = useMUD();
  const {
    components: { GuisePrototype },
  } = mud;

  const guiseEntities = useEntityQuery([Has(GuisePrototype)]);
  return useMemo(() => {
    return guiseEntities.map((guiseEntity) => getGuise(mud, guiseEntity));
  }, [mud, guiseEntities]);
};

export const useActiveGuise = (targetEntity: EntityIndex | undefined) => {
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

  return useGuise(guiseEntity);
};
