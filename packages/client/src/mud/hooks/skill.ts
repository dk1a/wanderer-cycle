import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { EntityIndex, Has } from "@latticexyz/recs";
import { useCallback, useMemo } from "react";
import { useMUD } from "../MUDContext";
import { getSkill } from "../utils/skill";
import { toastPromise } from "../utils/toast";

export const useSkill = (entity: EntityIndex | undefined) => {
  const { world, components } = useMUD();

  return useMemo(() => {
    if (entity === undefined) return undefined;
    return getSkill(world, components, entity);
  }, [world, components, entity]);
};

export const useSkillStrict = (entity: EntityIndex) => {
  const { world, components } = useMUD();

  return useMemo(() => {
    return getSkill(world, components, entity);
  }, [world, components, entity]);
};

export const useSkills = (entities: EntityIndex[]) => {
  const { world, components } = useMUD();

  return useMemo(() => {
    return entities.map((entity) => {
      return getSkill(world, components, entity);
    });
  }, [world, components, entities]);
};

export const useAllSkillEntities = () => {
  const {
    components: { SkillPrototype },
  } = useMUD();

  return useEntityQuery([Has(SkillPrototype)]);
};

export const useLearnedSkillEntities = (targetEntity: EntityIndex | undefined) => {
  const {
    world,
    components: { LearnedSkills },
  } = useMUD();

  const learnedSkills = useComponentValue(LearnedSkills, targetEntity);
  return useMemo(() => {
    const entityIds = learnedSkills?.value ?? [];
    return entityIds.map((entityId) => {
      const entity = world.entityToIndex.get(entityId);
      if (entity === undefined) throw new Error(`No index for entity id ${entityId}`);
      return entity;
    });
  }, [world, learnedSkills]);
};

export const useLearnCycleSkill = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems, components } = useMUD();

  return useCallback(
    async (skillEntity: EntityIndex) => {
      if (wandererEntity === undefined) throw new Error("No wanderer selected");
      const tx = await systems["system.LearnCycleSkill"].executeTyped(
        world.entities[wandererEntity],
        world.entities[skillEntity]
      );
      const skill = getSkill(world, components, skillEntity);
      await toastPromise(tx.wait(), `Learning ${skill.name}`, `${skill.name} learned!`);
    },
    [world, systems, components, wandererEntity]
  );
};

export const usePermSkill = (wandererEntity: EntityIndex | undefined) => {
  const { world, systems, components } = useMUD();

  return useCallback(
    async (skillEntity: EntityIndex) => {
      if (wandererEntity === undefined) throw new Error("No wanderer selected");
      const tx = await systems["system.PermSkill"].executeTyped(
        world.entities[wandererEntity],
        world.entities[skillEntity]
      );
      const skill = getSkill(world, components, skillEntity);
      await toastPromise(tx.wait(), `Use ${skill.name}`, `${skill.name} used`);
    },
    [world, systems, components, wandererEntity]
  );
};

export const useExecuteNoncombatSkill = () => {
  const { world, systems, components } = useMUD();

  return useCallback(
    async (cycleEntity: EntityIndex, skillEntity: EntityIndex) => {
      const tx = await systems["system.NoncombatSkill"].executeTyped(
        world.entities[cycleEntity],
        world.entities[skillEntity]
      );
      const skill = getSkill(world, components, skillEntity);
      await toastPromise(tx.wait(), `Use execute ${skill.name}`, `Execute ${skill.name} is a used`);
    },
    [world, systems, components]
  );
};
