import { EntityID, EntityIndex, getComponentValueStrict, Has, hasComponent, HasValue, World } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { useComponentValue } from "@latticexyz/react";
import { useMemo } from "react";
import { SetupResult } from "../setup";
import { useEntityQuery } from "../useEntityQuery";
import { EffectStatmodData } from "../utils/effectStatmod";
import { defaultAbiCoder, getAddress, keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { AffixPartId, LootAffix } from "../utils/getLootAffix";
import { EffectSource, getAppliedEffect, getEffectPrototype } from "../utils/getEffect";
import { ElementalStatmodTopic, StatmodTopic } from "../utils/topics";
import { getStatmodPrototype } from "../utils/getStatmodPrototype";
import { BigNumber } from "ethers";

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
//
// type GetWheelsCompletedComponents = Pick<SetupResult["components"], "Name" | "Wheel">;
//
// export function getWheelsCompletedEntity(
//   world: World,
//   components: GetWheelsCompletedComponents,
//   completedEntity: EntityIndex,
//   protoEntity: EntityIndex
// ) {
//   const { Name, Wheel} = components;
//
//
//   return {
//     protoEntity,
//     effectSource,
//   };
// }

export const useWheelsCompletedEntity = (
  wheelEntity: EntityIndex | undefined,
  wandererEntity: EntityIndex | undefined
) => {
  const { world, components } = useMUD();
  const { Wheel } = components;

  const wheelEntities = useEntityQuery([Has(Wheel)], true);

  return useMemo(() => {
    if (!wheelEntity) return [];
    if (!wandererEntity) return [];

    const mappedEntities = wheelEntities.map((protoEntity) => {
      const bytes = defaultAbiCoder.encode(
        ["uint256", "uint256"],
        [world.entities[wandererEntity], world.entities[protoEntity]]
      );
      const entityId = keccak256(bytes) as EntityID;
      return {
        protoEntity,
        completedEntity: world.entityToIndex.get(entityId),
      };
    });
    const filteredEntities = mappedEntities.filter(
      (entities): entities is { protoEntity: EntityIndex; completedEntity: EntityIndex } => {
        return entities.completedEntity ? wheelEntities.includes(entities.completedEntity) : false;
      }
    );
    // return filteredEntities.map(({ protoEntity, completedEntity }) =>
    //   getWheelsCompleted(world, components, completedEntity, protoEntity)
    // );
  }, [world, components, wheelEntities, wheelEntities, wandererEntity]);
};
