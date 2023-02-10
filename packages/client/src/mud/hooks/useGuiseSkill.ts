import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";
import { parseElemental } from "../utils/elemental";
import { parseScopedDuration } from "../utils/scopedDuration";

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

export const useGuiseSkill = (entity: EntityIndex) => {
  const {
    world,
    components: { SkillPrototype, SkillDescription, Name },
  } = useMUD();

  const skill = useComponentValue(SkillPrototype, entity);
  const description = useComponentValue(SkillDescription, entity);
  const name = useComponentValue(Name, entity);

  // skills should never be deleted
  if (!skill) {
    throw new Error("Invalid Skill for entity");
  }

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
