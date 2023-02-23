import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMemo } from "react";
import { useMUD } from "../MUDContext";

export const useLearnedSkillEntities = (entity: EntityIndex | undefined) => {
  const {
    world,
    components: { LearnedSkills },
  } = useMUD();

  const learnedSkills = useComponentValue(LearnedSkills, entity);
  return useMemo(() => {
    const entityIds = learnedSkills?.value ?? [];
    return entityIds.map((entityId) => {
      const entity = world.entityToIndex.get(entityId);
      if (entity === undefined) throw new Error(`No index for entity id ${entityId}`);
      return entity;
    });
  }, [world, learnedSkills]);
};
