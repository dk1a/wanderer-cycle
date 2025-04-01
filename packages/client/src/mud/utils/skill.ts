import { Entity, getComponentValueStrict } from "@latticexyz/recs";
import { ClientComponents } from "../createClientComponents";
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

export const getSkill = (components: ClientComponents, entity: Entity) => {
  const skill = getComponentValueStrict(components.SkillTemplate, entity);
  const description = getComponentValueStrict(
    components.SkillDescription,
    entity,
  );
  const name = getComponentValueStrict(components.SkillName, entity);
  const skillSpellDamage = getComponentValueStrict(
    components.SkillSpellDamage,
    entity,
  );
  const skillTemplateCooldown = getComponentValueStrict(
    components.SkillTemplateCooldown,
    entity,
  );
  const skillTemplateDuration = getComponentValueStrict(
    components.SkillTemplateDuration,
    entity,
  );

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
};
