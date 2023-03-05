import { useEntityQuery } from "../useEntityQuery";
import { EntityID, EntityIndex, getComponentValueStrict, Has, HasValue } from "@latticexyz/recs";
import { BigNumber } from "ethers";
import { defaultAbiCoder, keccak256, toUtf8Bytes } from "ethers/lib/utils";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { Elemental, StatmodElement, statmodElements } from "../utils/elemental";
import { getStatmodPrototype } from "../utils/getStatmodPrototype";
import { Op } from "../utils/op";
import { ElementalStatmodTopic, StatmodTopic } from "../utils/topics";

/**
 * Sum all statmod values for given operand filter
 */
function sumForOp(statmods: ReturnType<typeof useTopicStatmods>, opFilter: Op) {
  return statmods.filter(({ statmodPrototype: { op } }) => op === opFilter).reduce((acc, curr) => acc + curr.value, 0);
}

/**
 * Sum all statmod values for given operand and element filters
 */
function sumForElementalOp(statmods: ReturnType<typeof useTopicStatmods>, opFilter: Op, elementFilter: StatmodElement) {
  return statmods
    .filter(({ statmodPrototype: { op, element } }) => op === opFilter && element === elementFilter)
    .reduce((acc, curr) => acc + curr.value, 0);
}

export const useGetValuesFinal = (targetEntity: EntityIndex | undefined, topic: StatmodTopic, baseValue: number) => {
  const statmods = useTopicStatmods(targetEntity, topic);
  return useMemo(() => {
    const resultBadd = baseValue + sumForOp(statmods, Op.BADD);
    const resultMul = Math.floor((resultBadd * (100 + sumForOp(statmods, Op.MUL))) / 100);
    const resultAdd = resultMul + sumForOp(statmods, Op.ADD);
    return resultAdd;
  }, [baseValue, statmods]);
};

export const useGetValuesElementalFinal = (
  targetEntity: EntityIndex | undefined,
  topic: ElementalStatmodTopic,
  baseValues: Elemental
) => {
  const statmods = useTopicStatmods(targetEntity, topic);
  return useMemo(() => {
    const result = { ...baseValues };
    for (const element of statmodElements) {
      const resultBadd = baseValues[element] + sumForElementalOp(statmods, Op.BADD, element);
      const resultMul = Math.floor((resultBadd * (100 + sumForElementalOp(statmods, Op.MUL, element))) / 100);
      const resultAdd = resultMul + sumForElementalOp(statmods, Op.ADD, element);
      result[element] = resultAdd;
    }
    return result;
  }, [baseValues, statmods]);
};

export const useTopicStatmods = (
  targetEntity: EntityIndex | undefined,
  topic: StatmodTopic | ElementalStatmodTopic
) => {
  const {
    world,
    components: { StatmodScope, StatmodValue, FromPrototype, StatmodPrototype, Name, ReverseHashName },
  } = useMUD();

  const topicEntityId = useMemo(() => keccak256(toUtf8Bytes(topic)) as EntityID, [topic]);

  const scope = useMemo(() => {
    if (!targetEntity) return;
    return defaultAbiCoder.encode(["uint256", "uint256"], [world.entities[targetEntity], topicEntityId]);
  }, [world, targetEntity, topicEntityId]);

  const appliedEntities = useEntityQuery([HasValue(StatmodScope, { value: scope }), Has(StatmodValue)], true);

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
