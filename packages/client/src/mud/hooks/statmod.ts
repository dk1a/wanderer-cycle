import { useEntityQuery } from "@latticexyz/react";
import { EntityID, EntityIndex, getComponentValueStrict, Has, HasValue } from "@latticexyz/recs";
import { BigNumber } from "ethers";
import { defaultAbiCoder, keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getStatmodPrototype } from "../utils/getStatmodPrototype";
import { Op } from "../utils/op";
import { StatmodTopic } from "../utils/topics";

/**
 * Sum all statmod values for given operand filter
 */
function sumForOp(statmods: ReturnType<typeof useTopicStatmods>, opFilter: Op) {
  return statmods.filter(({ statmodPrototype: { op } }) => op === opFilter).reduce((acc, curr) => acc + curr.value, 0);
}

export const useGetValuesFinal = (targetEntity: EntityIndex | undefined, topic: StatmodTopic, baseValue: number) => {
  const statmods = useTopicStatmods(targetEntity, topic);
  const resultBadd = baseValue + sumForOp(statmods, Op.BADD);
  const resultMul = Math.floor(Math.floor(resultBadd * (100 + sumForOp(statmods, Op.MUL))) / 100);
  const resultAdd = resultMul + sumForOp(statmods, Op.ADD);
  return resultAdd;
};

export const useTopicStatmods = (targetEntity: EntityIndex | undefined, topic: StatmodTopic) => {
  const {
    world,
    components: { StatmodScope, StatmodValue, FromPrototype, StatmodPrototype, Name, ReverseHashName },
  } = useMUD();

  const topicEntityId = useMemo(() => keccak256(toUtf8Bytes(topic)) as EntityID, [topic]);

  const scope = useMemo(() => {
    if (!targetEntity) return;
    return defaultAbiCoder.encode(["uint256", "uint256"], [world.entities[targetEntity], topicEntityId]);
  }, [world, targetEntity, topicEntityId]);

  const appliedEntities = useEntityQuery(
    useMemo(() => [HasValue(StatmodScope, { value: scope }), Has(StatmodValue)], [StatmodScope, StatmodValue, scope])
  );

  return useMemo(() => {
    return appliedEntities.map((appliedEntity) => {
      const statmodValue = getComponentValueStrict(StatmodValue, appliedEntity);
      const fromPrototype = getComponentValueStrict(FromPrototype, appliedEntity);
      const protoEntity = world.entityToIndex.get(fromPrototype.value);
      if (!protoEntity) {
        throw new Error("statmod appliedEntities conversion: protoEntity is absent from world");
      }
      const statmodPrototype = getStatmodPrototype(world, { StatmodPrototype, Name, ReverseHashName }, protoEntity);

      return {
        appliedEntity,
        protoEntity,
        value: BigNumber.from(statmodValue.value).toNumber(),
        statmodPrototype,
      };
    });
  }, [world, StatmodValue, FromPrototype, StatmodPrototype, Name, ReverseHashName, appliedEntities]);
};
