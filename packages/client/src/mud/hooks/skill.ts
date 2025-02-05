import { useComponentValue, useEntityQuery } from "@latticexyz/react";
import { Entity, Has } from "@latticexyz/recs";
import { useCallback, useMemo } from "react";
import { useMUD } from "../../MUDContext";
import { getSkill } from "../utils/skill";

export const useSkill = (entity: Entity | undefined) => {
  const { components } = useMUD();

  return useMemo(() => {
    if (entity === undefined) return undefined;
    return getSkill(components, entity);
  }, [components, entity]);
};

export const useSkillStrict = (entity: Entity) => {
  const { components } = useMUD();

  return useMemo(() => {
    return getSkill(components, entity);
  }, [components, entity]);
};

export const useSkills = (entities: Entity[]) => {
  const { components } = useMUD();

  return useMemo(() => {
    return entities.map((entity) => {
      return getSkill(components, entity);
    });
  }, [components, entities]);
};

export const useAllSkillEntities = () => {
  const { components } = useMUD();

  return useEntityQuery([Has(components.SkillTemplate)]);
};

export const useLearnedSkillEntities = (targetEntity: Entity | undefined) => {
  const { components } = useMUD();

  const learnedSkills = useComponentValue(
    components.LearnedSkills,
    targetEntity,
  );

  return useMemo(() => {
    if (!learnedSkills || !Array.isArray(learnedSkills)) {
      return [];
    }

    return learnedSkills.map((entity: Entity) => {
      if (entity === undefined) {
        throw new Error(`No index for entity id ${entity}`);
      }
      return entity;
    });
  }, [learnedSkills]);
};

export const useLearnCycleSkill = (wandererEntity: Entity | undefined) => {
  const { systemCalls } = useMUD();

  return useCallback(
    async (skillEntity: Entity) => {
      if (wandererEntity === undefined) throw new Error("No wanderer selected");
      await systemCalls.learnCycleSkill(wandererEntity, skillEntity);
    },
    [wandererEntity, systemCalls],
  );
};

// export const usePermSkill = (wandererEntity: Entity | undefined) => {
//   const { systemCalls } = useMUD();
//
//   return useCallback(
//     async (skillEntity: Entity) => {
//       if (wandererEntity === undefined) throw new Error("No wanderer selected");
//       await systemCalls.permSkill(wandererEntity, skillEntity);
//     },
//     [systemCalls, wandererEntity],
//   );
// };
//
// export const useExecuteNoncombatSkill = () => {
//   const { systemCalls } = useMUD();
//
//   return useCallback(
//     async (cycleEntity: Entity, skillEntity: Entity) => {
//       await systemCalls.noncombatSkill(cycleEntity, skillEntity);
//     },
//     [systemCalls],
//   );
// };
