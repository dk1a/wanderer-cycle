import { EntityID, EntityIndex, getComponentValueStrict, HasValue } from "@latticexyz/recs";
import { BigNumber } from "ethers";
import { defaultAbiCoder, keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { useEntityQuery } from "../useEntityQuery";

export const useTopicStatmods = (targetEntity: EntityIndex | undefined, topic: string) => {
  const {
    world,
    components: { StatmodScope, StatmodValue, FromPrototype },
  } = useMUD();

  const topicEntityId = useMemo(() => keccak256(toUtf8Bytes(topic)) as EntityID, [topic]);

  const scope = useMemo(() => {
    if (!targetEntity) return;
    return defaultAbiCoder.encode(["uint256", "uint256"], [world.entities[targetEntity], topicEntityId]);
  }, [world, targetEntity, topicEntityId]);

  const appliedEntities = useEntityQuery(
    useMemo(() => [HasValue(StatmodScope, { value: scope })], [StatmodScope, scope])
  );

  return useMemo(() => {
    return appliedEntities.map((appliedEntity) => {
      const statmodValue = getComponentValueStrict(StatmodValue, appliedEntity);
      const fromPrototype = getComponentValueStrict(FromPrototype, appliedEntity);
      const protoEntity = world.entityToIndex.get(fromPrototype.value);
      if (!protoEntity) {
        throw new Error("statmod appliedEntities conversion: protoEntity is absent from world");
      }

      return {
        appliedEntity,
        protoEntity,
        value: BigNumber.from(statmodValue.value).toNumber(),
      };
    });
  }, [world, StatmodValue, FromPrototype, appliedEntities]);
};
