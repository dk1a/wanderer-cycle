import { EntityID, EntityIndex, getComponentValueStrict, Has } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { useComponentValue } from "@latticexyz/react";
import { useMemo } from "react";
import { SetupResult } from "../setup";
import { useEntityQuery } from "../useEntityQuery";
import { defaultAbiCoder, keccak256 } from "ethers/lib/utils";

export type WheelData = ReturnType<typeof getWheel>;
export type WheelCompletedData = ReturnType<typeof getWheel> & { completed: number };

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
    world,
    components: { ActiveWheel },
  } = useMUD();

  const activeWheel = useComponentValue(ActiveWheel, entity);

  return useMemo(() => {
    if (activeWheel === undefined) return;
    return world.entityToIndex.get(activeWheel.value);
  }, [world, activeWheel]);
};

export const useWheelsCompleted = (wandererEntity: EntityIndex | undefined): WheelCompletedData[] => {
  const mud = useMUD();
  const { world, components } = mud;
  const { Wheel, WheelsCompleted } = components;

  // TODO same issues as useAppliedEffects
  const wheelEntities = useEntityQuery([Has(Wheel)], true);
  const wheelsCompletedEntities = useEntityQuery([Has(WheelsCompleted)], true);

  return useMemo(() => {
    if (wandererEntity === undefined) return [];

    return wheelEntities.map((wheelEntity) => {
      const bytes = defaultAbiCoder.encode(
        ["uint256", "uint256"],
        [world.entities[wandererEntity], world.entities[wheelEntity]]
      );
      const compositeEntityId = keccak256(bytes) as EntityID;
      const compositeEntity = world.entityToIndex.get(compositeEntityId);

      let completed = 0;
      if (compositeEntity !== undefined && wheelsCompletedEntities.includes(compositeEntity)) {
        completed = getComponentValueStrict(WheelsCompleted, compositeEntity).value;
      }

      return {
        ...getWheel(mud, wheelEntity),
        completed,
      };
    });
  }, [mud, world, WheelsCompleted, wheelEntities, wheelsCompletedEntities, wandererEntity]);
};

const getWheel = ({ world, components: { Wheel, Name } }: SetupResult, entity: EntityIndex) => {
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
