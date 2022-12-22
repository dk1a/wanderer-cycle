// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";

import { LibSkill } from "../skill/LibSkill.sol";
import { LibCharstat, EL_L } from "../charstat/LibCharstat.sol";

struct Action {
  ActionType actionType;
  uint256 actionEntity;
}

enum ActionType {
  ATTACK,
  SKILL
}

// TODO this may work better via a component
struct ActorOpts {
  uint32 maxResistance;
}

library LibCombatAction {
  using LibCharstat for LibCharstat.Self;
  using LibSkill for LibSkill.Self;

  error LibCombat__InvalidActionType();

  struct Self {
    IUint256Component components;
    LibCharstat.Self attackerCharstat;
    ActorOpts attackerOpts;
    LibCharstat.Self defenderCharstat;
    ActorOpts defenderOpts;
  }

  function __construct(
    IUint256Component components,
    LibCharstat.Self memory attackerCharstat,
    ActorOpts memory attackerOpts,
    LibCharstat.Self memory defenderCharstat,
    ActorOpts memory defenderOpts
  ) internal pure returns (Self memory) {
    return Self({
      components: components,
      attackerCharstat: attackerCharstat,
      attackerOpts: attackerOpts,
      defenderCharstat: defenderCharstat,
      defenderOpts: defenderOpts
    });
  }

  function executeAction(
    Self memory __self,
    Action memory action
  ) internal {
    if (action.actionType == ActionType.ATTACK) {
      // deal damage to defender (updates currents)
      _dealAttackDamage(__self);
    } else if (action.actionType == ActionType.SKILL) {
      _useSkill(__self, action.actionEntity);
    } else {
      revert LibCombat__InvalidActionType();
    }
  }

  function _useSkill(
    Self memory __self,
    uint256 skillEntity
  ) private {
    LibSkill.Self memory libSkill = LibSkill.__construct(
      __self.components,
      __self.attackerCharstat.targetEntity,
      skillEntity
    );

    libSkill.requireCombat();

    // combat skills may target either self or enemy, depending on skill prototype
    uint256 targetEntity = libSkill.chooseCombatTarget(
      __self.defenderCharstat.targetEntity
    );
    // use skill
    libSkill.useSkill(targetEntity);

    // skill may need a follow-up attack and/or spell
    if (libSkill.skill.withAttack) {
      _dealAttackDamage(__self);
    }
    if (libSkill.skill.withSpell) {
      _dealSpellDamage(__self, libSkill.skill.spellDamage);
    }
  }

  function _dealAttackDamage(
    Self memory __self
  ) private {
    _dealDamage(__self, __self.attackerCharstat.getAttack());
  }

  function _dealSpellDamage(
    Self memory __self,
    uint32[EL_L] memory baseSpellDamage
  ) private {
    _dealDamage(__self, __self.attackerCharstat.getSpell(baseSpellDamage));
  }

  /**
   * @dev Modifies LifeCurrent according to elemental damage and resistance
   * Resistances are percentages (scaling of 1/100)
   */
  function _dealDamage(
    Self memory __self,
    uint32[EL_L] memory elemDamage
  ) private {
    uint32 maxResistance = __self.defenderOpts.maxResistance;
    assert(maxResistance <= 100);

    uint32[EL_L] memory resistance = __self.defenderCharstat.getResistance();

    // calculate total damage (elemental, 0 index isn't used)
    uint32 totalDamage = 0;
    for (uint256 i = 1; i < EL_L; i++) {
      uint32 elemResistance = resistance[i] < maxResistance ? resistance[i] : maxResistance;
      uint32 adjustedDamage = elemDamage[i] * (100 - elemResistance) / 100;
      totalDamage += adjustedDamage;
    }

    // modify life only if resistances didn't fully negate damage
    if (totalDamage == 0) return;

    // get life
    uint32 lifeCurrent = __self.defenderCharstat.getLifeCurrent();
    // subtract damage
    if (totalDamage >= lifeCurrent) {
      // life can't be negative
      lifeCurrent = 0;
    } else {
      lifeCurrent -= totalDamage;
    }
    // update life
    __self.defenderCharstat.setLifeCurrent(lifeCurrent);
  }
}