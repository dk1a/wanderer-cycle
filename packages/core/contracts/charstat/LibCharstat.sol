// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Statmod, Element, EL_L } from "../statmod/Statmod.sol";
import { Topics } from "./Topics.sol";
import { LibExperience, PStat, PS_L } from "./LibExperience.sol";

library LibCharstat {
  using Statmod for Statmod.Self;

  // ========== PRIMARY STATS (strength, arcana, dexterity) ==========
  function getBasePStat(
    Statmod.Self memory statmod,
    PStat pstatIndex
  ) internal view returns (uint32) {
    // TODO use some component that checks what to use here targetEntity
    //statmod.targetEntity
    if (false) {
      // ENTITY WITH EXPERIENCE
      uint32 experience = uint32(pstatIndex);// = ___; TODO get exp from some component
      return LibExperience.getLevel(experience);
    } else if (false) {
      // ENTITY MAP
      // TODO maybe change topic name?
      return statmod.getValuesFinal(Topics.MAP_LEVEL, 0);
    } else {
      revert('TODO: finish getBasePStats');
    }
  }

  function getPStat(
    Statmod.Self memory statmod,
    PStat pstatIndex
  ) internal view returns (uint32) {
    uint32 baseValue = getBasePStat(statmod, pstatIndex);

    return statmod.getValuesFinal(Topics.PSTAT()[uint256(pstatIndex)], baseValue);
  }

  // ========== ATTRIBUTES ==========
  function getLife(
    Statmod.Self memory statmod
  ) internal view returns (uint32) {
    uint32 strength = getPStat(statmod, PStat.STRENGTH);
    uint32 baseValue = 2 + 2 * strength;

    return statmod.getValuesFinal(Topics.LIFE, baseValue);
  }

  function getMana(
    Statmod.Self memory statmod
  ) internal view returns (uint32) {
    uint32 arcana = getPStat(statmod, PStat.ARCANA);
    uint32 baseValue = 4 * arcana;

    return statmod.getValuesFinal(Topics.MANA, baseValue);
  }

  function getFortune(
    Statmod.Self memory statmod
  ) internal view returns (uint32) {
    return statmod.getValuesFinal(Topics.FORTUNE, 0);
  }

  function getConnection(
    Statmod.Self memory statmod
  ) internal view returns (uint32) {
    return statmod.getValuesFinal(Topics.CONNECTION, 0);
  }

  function getLifeRegen(
    Statmod.Self memory statmod
  ) internal view returns (uint32) {
    return statmod.getValuesFinal(Topics.LIFE_REGEN, 0);
  }

  function getManaRegen(
    Statmod.Self memory statmod
  ) internal view returns (uint32) {
    return statmod.getValuesFinal(Topics.MANA_REGEN, 0);
  }

  // ========== ELEMENTAL ==========
  function getAttack(
    Statmod.Self memory statmod
  ) internal view returns (uint32[EL_L] memory) {
    uint32 strength = getPStat(statmod, PStat.STRENGTH);
    // strength increases physical base attack damage
    uint32[EL_L] memory baseValues = [uint32(0), strength / 2 + 1, 0, 0, 0];

    return statmod.getValuesElementalFinal(Topics.ATTACK, baseValues);
  }

  function getSpell(
    Statmod.Self memory statmod,
    uint32[EL_L] memory baseValues
  ) internal view returns (uint32[EL_L] memory) {
    uint32 arcana = getPStat(statmod, PStat.ARCANA);
    // arcana increases non-zero base spell damage
    for (uint256 i; i < EL_L; i++) {
      if (baseValues[i] > 0) {
        // TODO u sure it's fine to modify in-place like that?
        baseValues[i] += arcana;
      }
    }

    return statmod.getValuesElementalFinal(Topics.SPELL, baseValues);
  }

  function getResistance(
    Statmod.Self memory statmod
  ) internal view returns (uint32[EL_L] memory) {
    uint32 dexterity = getPStat(statmod, PStat.DEXTERITY);
    // dexterity increases base physical resistance
    uint32[EL_L] memory baseValues = [uint32((dexterity / 4) * 4), 0, 0, 0, 0];

    return statmod.getValuesElementalFinal(Topics.SPELL, baseValues);
  }

  // ========== CURRENTS ==========
  // !!!!!!!!!!! TODO CURRENTS !!!!!!!!!
  /*function getInitialCurrents(
    Statmod.Self memory statmod
  ) internal view returns (Currents memory) {
      uint32[PS_L] memory pstats = getPStats(instance);
      return Currents({
          life: getLife(instance, pstats),
          mana: getMana(instance, pstats)
      });
  }

  /**
   * @dev reduces `currents` to be not-greater-than their max values
   *
  function adjustCurrents(
      InstanceId.Id instance,
      uint32[PS_L] memory pstats,
      Currents memory currents
  ) internal view returns (Currents memory) {
      uint32 lifeMax = getLife(instance, pstats);
      if (currents.life > lifeMax) {
          currents.life = lifeMax;
      }

      uint32 manaMax = getMana(instance, pstats);
      if (currents.mana > manaMax) {
          currents.mana = manaMax;
      }

      return currents;
  }*/

  // ========== ROUND DAMAGE ==========
  function getRoundDamage(
    Statmod.Self memory statmod
  ) internal view returns (uint32[EL_L] memory) {
    return statmod.getValuesElementalFinal(Topics.SPELL, [uint32(0), 0, 0, 0, 0]);
  }
}