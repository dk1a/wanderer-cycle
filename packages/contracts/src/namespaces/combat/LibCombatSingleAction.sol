// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SkillTemplate } from "../skill/codegen/tables/SkillTemplate.sol";
import { SkillSpellDamage } from "../skill/codegen/tables/SkillSpellDamage.sol";
import { CombatActionType } from "../../codegen/common.sol";
import { EleStat_length, CombatAction, CombatActorOpts } from "../../CustomTypes.sol";

import { charstatSystem } from "../charstat/codegen/systems/CharstatSystemLib.sol";
import { skillSystem } from "../skill/codegen/systems/SkillSystemLib.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";
import { LibSkill } from "../skill/LibSkill.sol";

struct CombatActionDamageLog {
  bool withAttack;
  bool withSpell;
  uint32[EleStat_length] attackDamage;
  uint32[EleStat_length] spellDamage;
}

library LibCombatSingleAction {
  error LibCombatSingleAction_InvalidActionType();

  function executeAction(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    CombatAction memory action,
    CombatActorOpts memory defenderOpts
  ) public returns (CombatActionDamageLog memory damageLog) {
    if (action.actionType == CombatActionType.ATTACK) {
      // Deal damage to defender (updates currents)
      damageLog.attackDamage = _dealAttackDamage(attackerEntity, defenderEntity, defenderOpts);
      damageLog.withAttack = true;
    } else if (action.actionType == CombatActionType.SKILL) {
      return _useSkill(attackerEntity, defenderEntity, action.actionEntity, defenderOpts);
    } else {
      revert LibCombatSingleAction_InvalidActionType();
    }
  }

  function _useSkill(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    bytes32 skillEntity,
    CombatActorOpts memory defenderOpts
  ) private returns (CombatActionDamageLog memory damageLog) {
    LibSkill.requireCombatType(skillEntity);

    // Combat skills may target either self or enemy, depending on TargetType
    bytes32 targetEntity = LibSkill.chooseCombatTarget(attackerEntity, skillEntity, defenderEntity);
    // Use skill
    skillSystem.useSkill(attackerEntity, skillEntity, targetEntity);
    uint32[EleStat_length] memory spellDamage = SkillSpellDamage.get(skillEntity);

    // Skill may need a follow-up attack and/or spell
    if (SkillTemplate.getWithAttack(skillEntity)) {
      damageLog.attackDamage = _dealAttackDamage(attackerEntity, defenderEntity, defenderOpts);
      damageLog.withAttack = true;
    }
    if (SkillTemplate.getWithSpell(skillEntity)) {
      damageLog.spellDamage = _dealSpellDamage(attackerEntity, defenderEntity, spellDamage, defenderOpts);
      damageLog.withSpell = true;
    }
  }

  function _dealAttackDamage(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    CombatActorOpts memory defenderOpts
  ) private returns (uint32[EleStat_length] memory) {
    return _dealDamage(defenderEntity, LibCharstat.getAttack(attackerEntity), defenderOpts);
  }

  function _dealSpellDamage(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    uint32[EleStat_length] memory baseSpellDamage,
    CombatActorOpts memory defenderOpts
  ) private returns (uint32[EleStat_length] memory) {
    return _dealDamage(defenderEntity, LibCharstat.getSpell(attackerEntity, baseSpellDamage), defenderOpts);
  }

  /**
   * @dev Modifies LifeCurrent according to elemental damage and resistance
   * Resistances are percentages (scaling of 1/100)
   */
  function _dealDamage(
    bytes32 defenderEntity,
    uint32[EleStat_length] memory elemDamage,
    CombatActorOpts memory defenderOpts
  ) private returns (uint32[EleStat_length] memory adjustedDamage) {
    uint32 maxResistance = defenderOpts.maxResistance;
    assert(maxResistance <= 100);

    uint32[EleStat_length] memory resistance = LibCharstat.getResistance(defenderEntity);

    // Calculate total damage (elemental, 0 index isn't used)
    uint32 totalDamage = 0;
    for (uint256 i = 1; i < EleStat_length; i++) {
      uint32 elemResistance = resistance[i] < maxResistance ? resistance[i] : maxResistance;
      adjustedDamage[i] = (elemDamage[i] * (100 - elemResistance)) / 100;
      totalDamage += adjustedDamage[i];
    }

    // Modify life only if resistances didn't fully negate damage
    if (totalDamage == 0) return adjustedDamage;

    // Get life
    uint32 lifeCurrent = LibCharstat.getLifeCurrent(defenderEntity);
    // Subtract damage
    if (totalDamage >= lifeCurrent) {
      // Life can't be negative
      lifeCurrent = 0;
    } else {
      lifeCurrent -= totalDamage;
    }
    // Update life
    charstatSystem.setLifeCurrent(defenderEntity, lifeCurrent);
  }
}
