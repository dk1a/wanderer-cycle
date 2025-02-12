// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SkillTemplate, SkillSpellDamage } from "../codegen/index.sol";
import { CombatActionType } from "../../../codegen/common.sol";
import { EleStat_length, CombatAction, CombatActorOpts } from "../../../CustomTypes.sol";

import { LibSkill } from "../skill/LibSkill.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

library LibCombatAction {
  error LibCombat__InvalidActionType();

  function executeAction(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    CombatAction memory action,
    CombatActorOpts memory defenderOpts
  ) internal {
    if (action.actionType == CombatActionType.ATTACK) {
      // deal damage to defender (updates currents)
      _dealAttackDamage(attackerEntity, defenderEntity, defenderOpts);
    } else if (action.actionType == CombatActionType.SKILL) {
      _useSkill(attackerEntity, defenderEntity, action.actionEntity, defenderOpts);
    } else {
      revert LibCombat__InvalidActionType();
    }
  }

  function _useSkill(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    bytes32 skillEntity,
    CombatActorOpts memory defenderOpts
  ) private {
    LibSkill.requireCombat(skillEntity);

    // combat skills may target either self or enemy, depending on skill prototype
    bytes32 targetEntity = LibSkill.chooseCombatTarget(attackerEntity, skillEntity, defenderEntity);
    // use skill
    LibSkill.useSkill(attackerEntity, skillEntity, targetEntity);
    uint32[EleStat_length] memory spellDamage = SkillSpellDamage.get(skillEntity);

    // skill may need a follow-up attack and/or spell
    if (SkillTemplate.getWithAttack(skillEntity)) {
      _dealAttackDamage(attackerEntity, defenderEntity, defenderOpts);
    }
    if (SkillTemplate.getWithSpell(skillEntity)) {
      _dealSpellDamage(attackerEntity, defenderEntity, spellDamage, defenderOpts);
    }
  }

  function _dealAttackDamage(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    CombatActorOpts memory defenderOpts
  ) private {
    _dealDamage(defenderEntity, LibCharstat.getAttack(attackerEntity), defenderOpts);
  }

  function _dealSpellDamage(
    bytes32 attackerEntity,
    bytes32 defenderEntity,
    uint32[EleStat_length] memory baseSpellDamage,
    CombatActorOpts memory defenderOpts
  ) private {
    _dealDamage(defenderEntity, LibCharstat.getSpell(attackerEntity, baseSpellDamage), defenderOpts);
  }

  /**
   * @dev Modifies LifeCurrent according to elemental damage and resistance
   * Resistances are percentages (scaling of 1/100)
   */
  function _dealDamage(
    bytes32 defenderEntity,
    uint32[EleStat_length] memory elemDamage,
    CombatActorOpts memory defenderOpts
  ) private {
    uint32 maxResistance = defenderOpts.maxResistance;
    assert(maxResistance <= 100);

    uint32[EleStat_length] memory resistance = LibCharstat.getResistance(defenderEntity);

    // calculate total damage (elemental, 0 index isn't used)
    uint32 totalDamage = 0;
    for (uint256 i = 1; i < EleStat_length; i++) {
      uint32 elemResistance = resistance[i] < maxResistance ? resistance[i] : maxResistance;
      uint32 adjustedDamage = (elemDamage[i] * (100 - elemResistance)) / 100;
      totalDamage += adjustedDamage;
    }

    // modify life only if resistances didn't fully negate damage
    if (totalDamage == 0) return;

    // get life
    uint32 lifeCurrent = LibCharstat.getLifeCurrent(defenderEntity);
    // subtract damage
    if (totalDamage >= lifeCurrent) {
      // life can't be negative
      lifeCurrent = 0;
    } else {
      lifeCurrent -= totalDamage;
    }
    // update life
    LibCharstat.setLifeCurrent(defenderEntity, lifeCurrent);
  }
}
