import { EntityIndex, getComponentValueStrict, Has } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { useComponentValue } from "@latticexyz/react";
import { useMemo } from "react";
import { SetupResult } from "../setup";
import { useEntityQuery } from "../useEntityQuery";

export type WheelData = ReturnType<typeof getWheel>;
export const getWheel = ({ world, components: { Wheel, Name } }: SetupResult, entity: EntityIndex) => {
  const wheel = getComponentValueStrict(Wheel, entity);
  const name = getComponentValueStrict(Name, entity);

  return {
    wheel,
    name,
    entity,
    wheelEntityId: world.entities[entity],
    totalIdentityRequired: wheel.totalIdentityRequired,
    charges: wheel.charges,
    isIsolated: wheel.isIsolated,
  };
};
export const useWheels = () => {
  const mud = useMUD();
  const {
    components: { Wheel },
  } = mud;

  const wheelEntities = useEntityQuery([Has(Wheel)], true);
  return useMemo(() => {
    return wheelEntities.map((wheelEntity) => getWheel(mud, wheelEntity));
  }, [mud, wheelEntities]);
};
export const useWheel = (entity: EntityIndex | undefined) => {
  const mud = useMUD();

  return useMemo(() => {
    if (entity === undefined) return;
    return getWheel(mud, entity);
  }, [mud, entity]);
};

export const useActiveWheel = (entity: EntityIndex | undefined) => {
  const {
    components: { ActiveWheel },
  } = useMUD();

  const activeWheel = useComponentValue(ActiveWheel, entity);

  return activeWheel?.value;
};
