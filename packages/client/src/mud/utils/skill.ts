import { EntityIndex, getComponentValueStrict, World } from "@latticexyz/recs";
import { SetupResult } from "../setup";
import { parseElemental } from "./elemental";
import { parseScopedDuration } from "./scopedDuration";

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

type GetSkillComponents = Pick<SetupResult["components"], "SkillPrototype" | "SkillDescription" | "Name">;

export const getSkill = (world: World, components: GetSkillComponents, entity: EntityIndex) => {
  const { SkillPrototype, SkillDescription, Name } = components;
  const skill = getComponentValueStrict(SkillPrototype, entity);
  const description = getComponentValueStrict(SkillDescription, entity);
  const name = getComponentValueStrict(Name, entity);

  const skillType = skill.skillType as SkillType;
  const effectTarget = skill.effectTarget as TargetType;

  return {
    entity,
    entityId: world.entities[entity],
    name: name?.value ?? "",
    requiredLevel: skill.requiredLevel,
    skillType,
    skillTypeName: skillTypeNames[skillType],
    withAttack: skill.withAttack,
    withSpell: skill.withSpell,
    cost: skill.cost,
    duration: parseScopedDuration(skill.duration_timeScopeId, skill.duration_timeValue),
    cooldown: parseScopedDuration(skill.cooldown_timeScopeId, skill.cooldown_timeValue),
    effectTarget,
    effectTargetName: targetTypeNames[effectTarget],
    spellDamage: parseElemental(
      skill.spellDamage_all,
      skill.spellDamage_physical,
      skill.spellDamage_fire,
      skill.spellDamage_cold,
      skill.spellDamage_poison
    ),

    description: description?.value ?? "",
  };
};
