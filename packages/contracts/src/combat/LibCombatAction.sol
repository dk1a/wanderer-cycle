// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { SkillTemplate, SkillSpellDamage } from "../codegen/index.sol";
import { ActionType } from "../codegen/common.sol";
import { EleStat_length } from "../CustomTypes.sol";

import { LibSkill } from "../skill/LibSkill.sol";
import { LibCharstat } from "../charstat/LibCharstat.sol";

struct Action {
  ActionType actionType;
  bytes32 actionEntity;
}

struct ActorOpts {
  uint32 maxResistance;
}

library LibCombatAction {
  error LibCombat__InvalidActionType();

  function executeAction(
    bytes32 targetEntity,
    bytes32 userEntity,
    bytes32 enemyEntity,
    Action memory action,
    ActorOpts memory defenderOpts
  ) internal {
    if (action.actionType == ActionType.ATTACK) {
      // deal damage to defender (updates currents)
      _dealAttackDamage(targetEntity, userEntity, defenderOpts);
    } else if (action.actionType == ActionType.SKILL) {
      _useSkill(userEntity, enemyEntity, action.actionEntity, defenderOpts);
    } else {
      revert LibCombat__InvalidActionType();
    }
  }

  function _useSkill(
    bytes32 userEntity,
    bytes32 enemyEntity,
    bytes32 skillEntity,
    ActorOpts memory defenderOpts
  ) private {
    LibSkill.requireCombat(skillEntity);

    // combat skills may target either self or enemy, depending on skill prototype
    bytes32 targetEntity = LibSkill.chooseCombatTarget(userEntity, skillEntity, enemyEntity);
    // use skill
    LibSkill.useSkill(userEntity, skillEntity, targetEntity);
    uint32[EleStat_length] memory spellDamage = SkillSpellDamage.get(skillEntity);

    // skill may need a follow-up attack and/or spell
    if (SkillTemplate.getWithAttack(skillEntity)) {
      _dealAttackDamage(targetEntity, userEntity, defenderOpts);
    }
    if (SkillTemplate.getWithSpell(skillEntity)) {
      _dealSpellDamage(targetEntity, userEntity, spellDamage, defenderOpts);
    }
  }

  function _dealAttackDamage(bytes32 targetEntity, bytes32 userEntity, ActorOpts memory defenderOpts) private {
    _dealDamage(targetEntity, LibCharstat.getAttack(userEntity), defenderOpts);
  }

  function _dealSpellDamage(
    bytes32 targetEntity,
    bytes32 userEntity,
    uint32[EleStat_length] memory baseSpellDamage,
    ActorOpts memory defenderOpts
  ) private {
    _dealDamage(targetEntity, LibCharstat.getSpell(userEntity, baseSpellDamage), defenderOpts);
  }

  /**
   * @dev Modifies LifeCurrent according to elemental damage and resistance
   * Resistances are percentages (scaling of 1/100)
   */
  function _dealDamage(
    bytes32 targetEntity,
    uint32[EleStat_length] memory elemDamage,
    ActorOpts memory defenderOpts
  ) private {
    uint32 maxResistance = defenderOpts.maxResistance;
    assert(maxResistance <= 100);

    uint32[EleStat_length] memory resistance = LibCharstat.getResistance(targetEntity);

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
    uint32 lifeCurrent = LibCharstat.getLifeCurrent(targetEntity);
    // subtract damage
    if (totalDamage >= lifeCurrent) {
      // life can't be negative
      lifeCurrent = 0;
    } else {
      lifeCurrent -= totalDamage;
    }
    // update life
    LibCharstat.setLifeCurrent(targetEntity, lifeCurrent);
  }
}
