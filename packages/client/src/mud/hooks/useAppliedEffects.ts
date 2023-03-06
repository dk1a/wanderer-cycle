import { EntityID, EntityIndex, Has } from "@latticexyz/recs";
import { defaultAbiCoder, keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";
import { getAppliedEffect } from "../utils/getEffect";

const effectSubsystemId = keccak256(toUtf8Bytes("system.Effect"));

export const useAppliedEffects = (targetEntity: EntityIndex | undefined) => {
  const { world, components } = useMUD();
  const { EffectPrototype, AppliedEffect } = components;

  // TODO this is horrendous and won't scale, you need a keyTuple from v2 world here
  // (or just add a component to track applied effect's targetEntity via HasValue)
  const effectProtoEntities = useEntityQuery([Has(EffectPrototype)]);
  const appliedEffectEntities = useEntityQuery([Has(AppliedEffect)], true);

  return useMemo(() => {
    if (!targetEntity) return [];

    const mappedEntities = effectProtoEntities.map((protoEntity) => {
      const bytes = defaultAbiCoder.encode(
        ["uint256", "uint256", "uint256"],
        [effectSubsystemId, world.entities[targetEntity], world.entities[protoEntity]]
      );
      const entityId = keccak256(bytes) as EntityID;
      return {
        protoEntity,
        appliedEntity: world.entityToIndex.get(entityId),
      };
    });
    const filteredEntities = mappedEntities.filter(
      (entities): entities is { protoEntity: EntityIndex; appliedEntity: EntityIndex } => {
        return entities.appliedEntity ? appliedEffectEntities.includes(entities.appliedEntity) : false;
      }
    );

    return filteredEntities.map(({ protoEntity, appliedEntity }) =>
      getAppliedEffect(world, components, appliedEntity, protoEntity)
    );
  }, [world, components, effectProtoEntities, appliedEffectEntities, targetEntity]);
};
