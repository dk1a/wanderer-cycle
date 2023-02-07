import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";
import { Element } from "../utils/elemental";
import { Op } from "../utils/op";

export enum EffectRemovability {
  BUFF,
  DEBUFF,
  PERSISTENT,
}

export const useStatmodPrototype = (entity: EntityIndex) => {
  const {
    world,
    components: { StatmodPrototype, Name, ReverseHashName },
  } = useMUD();

  const statmodPrototype = useComponentValue(StatmodPrototype, entity);

  const topicEntity = useMemo(
    () => (statmodPrototype ? world.entityToIndex.get(statmodPrototype.topicEntity) : undefined),
    [world, statmodPrototype]
  );
  const name = useComponentValue(Name, entity);
  // TODO is topicName even needed?
  const topicName = useComponentValue(ReverseHashName, topicEntity);

  if (!statmodPrototype) return;

  return {
    entity,
    name,

    element: statmodPrototype.element as Element,
    op: statmodPrototype.op as Op,

    topicEntity,
    topicName,
  };
};
