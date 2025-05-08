import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";
import { parseElementalArray } from "./elemental";
import { getDurationRecord, getDurationRecordStrict } from "./duration";

export type SkillData = ReturnType<typeof getSkill>;

export enum SkillType {
  COMBAT,
  NONCOMBAT,
  PASSIVE,
}

export const skillTypeNames = {
  [SkillType.COMBAT]: "combat",
  [SkillType.NONCOMBAT]: "noncombat",
  [SkillType.PASSIVE]: "passive",
};

export enum TargetType {
  SELF,
  ENEMY,
  ALLY,
  SELF_OR_ALLY,
}

export const targetTypeNames = {
  [TargetType.SELF]: "self",
  [TargetType.ENEMY]: "enemy",
  [TargetType.ALLY]: "ally",
  [TargetType.SELF_OR_ALLY]: "self or ally",
};

export function getSkill(state: StateLocal, entity: Hex) {
  const skill = getRecordStrict({
    state,
    table: mudTables.skill__SkillTemplate,
    key: { entity },
  });
  const description = getRecordStrict({
    state,
    table: mudTables.skill__SkillDescription,
    key: { entity },
  });
  const skillSpellDamage = getRecordStrict({
    state,
    table: mudTables.skill__SkillSpellDamage,
    key: { entity },
  });
  const skillTemplateCooldown = getDurationRecordStrict({
    state,
    table: mudTables.skill__SkillTemplateCooldown,
    key: { entity },
  });
  const skillTemplateDuration = getDurationRecordStrict({
    state,
    table: mudTables.skill__SkillTemplateDuration,
    key: { entity },
  });

  const skillType = skill.skillType as SkillType;
  const targetType = skill.targetType as TargetType;

  return {
    entity,
    name: getSkillName(state, entity),
    requiredLevel: skill.requiredLevel,
    skillType,
    skillTypeName: skillTypeNames[skillType],
    withAttack: skill.withAttack,
    withSpell: skill.withSpell,
    cost: skill.cost,
    templateDuration: skillTemplateDuration,
    templateCooldown: skillTemplateCooldown,
    targetType,
    targetTypeName: targetTypeNames[targetType],
    spellDamage: parseElementalArray(skillSpellDamage.value),

    description: description?.value ?? "",
  };
}

export function getSkillName(state: StateLocal, entity: Hex) {
  const name = getRecordStrict({
    state,
    table: mudTables.skill__SkillName,
    key: { entity },
  });
  return name.name;
}

export function getLearnedSkillEntities(state: StateLocal, targetEntity: Hex) {
  const result = getRecord({
    state,
    table: mudTables.skill__LearnedSkills,
    key: { entity: targetEntity },
  });
  return result?.skillEntities ?? [];
}

// targetEntity is the skill user, and the one affected by the cooldown
export function getSkillCooldown(
  state: StateLocal,
  targetEntity: Hex,
  skillEntity: Hex,
) {
  return getDurationRecord({
    state,
    table: mudTables.skill__SkillCooldown,
    key: { targetEntity, applicationEntity: skillEntity },
  });
}
