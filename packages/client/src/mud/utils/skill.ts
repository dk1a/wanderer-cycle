import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { getRecordStrict, mudTables, StateLocal } from "../stash";
import { parseElementalArray } from "./elemental";

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
    table: mudTables.root__SkillTemplate,
    key: { entity },
  });
  const description = getRecordStrict({
    state,
    table: mudTables.root__SkillDescription,
    key: { entity },
  });
  const name = getRecordStrict({
    state,
    table: mudTables.root__SkillName,
    key: { entity },
  });
  const skillSpellDamage = getRecordStrict({
    state,
    table: mudTables.root__SkillSpellDamage,
    key: { entity },
  });
  const skillTemplateCooldown = getRecordStrict({
    state,
    table: mudTables.root__SkillTemplateCooldown,
    key: { entity },
  });
  const skillTemplateDuration = getRecordStrict({
    state,
    table: mudTables.root__SkillTemplateDuration,
    key: { entity },
  });

  const skillType = skill.skillType as SkillType;
  const targetType = skill.targetType as TargetType;

  return {
    entity,
    name: name?.name ?? "",
    requiredLevel: skill.requiredLevel,
    skillType,
    skillTypeName: skillTypeNames[skillType],
    withAttack: skill.withAttack,
    withSpell: skill.withSpell,
    cost: skill.cost,
    duration: skillTemplateDuration,
    cooldown: skillTemplateCooldown,
    targetType,
    targetTypeName: targetTypeNames[targetType],
    spellDamage: parseElementalArray(skillSpellDamage.value),

    description: description?.value ?? "",
  };
}

export function getLearnedSkillEntities(state: StateLocal, targetEntity: Hex) {
  const result = getRecord({
    state,
    table: mudTables.root__LearnedSkills,
    key: { entity: targetEntity },
  });
  return result?.entityIdSet ?? [];
}
