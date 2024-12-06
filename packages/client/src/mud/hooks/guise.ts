import { useMemo } from "react";
import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { Has, Entity } from "@latticexyz/recs";
import { getGuise } from "../utils/guise";
import { useMUD } from "../../MUDContext";

export const useGuise = (entity: Entity | undefined) => {
  const { components } = useMUD();

  return useMemo(() => {
    if (entity === undefined) return;
    return getGuise(components, entity);
  }, [components, entity]);
};

export const useGuises = () => {
  const { components } = useMUD();
  const { GuisePrototype } = components;

  const guiseEntities = useEntityQuery([Has(GuisePrototype)]);
  return useMemo(() => {
    return guiseEntities.map((guiseEntity) =>
      getGuise(components, guiseEntity),
    );
  }, [components, guiseEntities]);
};

export const useActiveGuise = (targetEntity: Entity | undefined) => {
  const { components } = useMUD();
  const { ActiveGuise } = components;

  const activeGuise = useComponentValue(ActiveGuise, targetEntity);
  const guiseEntity = activeGuise?.toEntity as Entity | undefined;

  return useGuise(guiseEntity);
};
