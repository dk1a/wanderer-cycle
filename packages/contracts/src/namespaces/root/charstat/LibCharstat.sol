// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { Experience, LifeCurrent, ManaCurrent } from "../codegen/index.sol";

import { Statmod } from "../../statmod/Statmod.sol";
import { StatmodTopics, StatmodTopic } from "../../statmod/StatmodTopic.sol";
import { LibExperience } from "./LibExperience.sol";

import { StatmodOp, EleStat } from "../../../codegen/common.sol";
import { PStat, PStat_length, EleStat_length } from "../../../CustomTypes.sol";

library LibCharstat {
  // ========== PRIMARY STATS (strength, arcana, dexterity) ==========
  function getBasePStat(bytes32 targetEntity, PStat pstatIndex) internal view returns (uint32) {
    if (LibExperience.hasExp(targetEntity)) {
      // if entity uses exp component, use that for primary stats
      return LibExperience.getPStat(targetEntity, pstatIndex);
    } else {
      // otherwise try a special statmod
      return Statmod.getValuesFinal(targetEntity, StatmodTopics.LEVEL, 0);
    }
  }

  function getPStat(bytes32 targetEntity, PStat pstat) internal view returns (uint32) {
    uint32 baseValue = getBasePStat(targetEntity, pstat);

    return Statmod.getValuesFinal(targetEntity, StatmodTopics.PSTAT()[uint256(pstat)], baseValue);
  }

  function getPStats(bytes32 targetEntity) internal view returns (uint32[PStat_length] memory pstats) {
    for (uint256 i; i < PStat_length; i++) {
      pstats[i] = getPStat(targetEntity, PStat(i));
    }
    return pstats;
  }

  // ========== ATTRIBUTES ==========
  function getLife(bytes32 targetEntity) internal view returns (uint32) {
    uint32 strength = getPStat(targetEntity, PStat.STRENGTH);
    uint32 baseValue = 2 + 2 * strength;

    return Statmod.getValuesFinal(targetEntity, StatmodTopics.LIFE, baseValue);
  }

  function getMana(bytes32 targetEntity) internal view returns (uint32) {
    uint32 arcana = getPStat(targetEntity, PStat.ARCANA);
    uint32 baseValue = 4 * arcana;

    return Statmod.getValuesFinal(targetEntity, StatmodTopics.MANA, baseValue);
  }

  function getFortune(bytes32 targetEntity) internal view returns (uint32) {
    return Statmod.getValuesFinal(targetEntity, StatmodTopics.FORTUNE, 0);
  }

  function getConnection(bytes32 targetEntity) internal view returns (uint32) {
    return Statmod.getValuesFinal(targetEntity, StatmodTopics.CONNECTION, 0);
  }

  function getLifeRegen(bytes32 targetEntity) internal view returns (uint32) {
    return Statmod.getValuesFinal(targetEntity, StatmodTopics.LIFE_GAINED_PER_TURN, 0);
  }

  // ========== ELEMENTAL ==========
  function getAttack(bytes32 targetEntity) internal view returns (uint32[EleStat_length] memory) {
    uint32 strength = getPStat(targetEntity, PStat.STRENGTH);
    // strength increases physical base attack damage
    uint32[EleStat_length] memory baseValues = [uint32(0), strength / 2 + 1, 0, 0, 0];

    return Statmod.getValuesElementalFinal(targetEntity, StatmodTopics.ATTACK, baseValues);
  }

  function getSpell(
    bytes32 targetEntity,
    uint32[EleStat_length] memory baseValues
  ) internal view returns (uint32[EleStat_length] memory) {
    uint32 arcana = getPStat(targetEntity, PStat.ARCANA);
    // arcana increases non-zero base spell damage
    for (uint256 i; i < EleStat_length; i++) {
      if (baseValues[i] > 0) {
        // TODO u sure it's fine to modify in-place like that?
        baseValues[i] += arcana;
      }
    }

    return Statmod.getValuesElementalFinal(targetEntity, StatmodTopics.SPELL, baseValues);
  }

  function getResistance(bytes32 targetEntity) internal view returns (uint32[EleStat_length] memory) {
    uint32 dexterity = getPStat(targetEntity, PStat.DEXTERITY);
    // dexterity increases base physical resistance
    uint32[EleStat_length] memory baseValues = [uint32((dexterity / 4) * 4), 0, 0, 0, 0];

    return Statmod.getValuesElementalFinal(targetEntity, StatmodTopics.RESISTANCE, baseValues);
  }

  // ========== CURRENTS ==========
  function getLifeCurrent(bytes32 targetEntity) internal view returns (uint32) {
    uint32 lifeMax = getLife(targetEntity);
    uint32 lifeCurrent = LifeCurrent.get(targetEntity);
    if (lifeCurrent > lifeMax) {
      return lifeMax;
    } else {
      return uint32(lifeCurrent);
    }
  }

  function setLifeCurrent(bytes32 targetEntity, uint32 value) internal {
    LifeCurrent.set(targetEntity, value);
  }

  function getManaCurrent(bytes32 targetEntity) internal view returns (uint32) {
    uint32 manaMax = getMana(targetEntity);
    uint32 manaCurrent = ManaCurrent.get(targetEntity);

    if (manaCurrent > manaMax) {
      return manaMax;
    } else {
      return uint32(manaCurrent);
    }
  }

  function setManaCurrent(bytes32 targetEntity, uint32 value) internal {
    ManaCurrent.set(targetEntity, value);
  }

  /**
   * @dev Set currents to max values
   */
  function setFullCurrents(bytes32 targetEntity) internal {
    setLifeCurrent(targetEntity, getLife(targetEntity));
    setManaCurrent(targetEntity, getMana(targetEntity));
  }

  // ========== ROUND DAMAGE ==========
  function getRoundDamage(bytes32 targetEntity) internal view returns (uint32[EleStat_length] memory) {
    return Statmod.getValuesElementalFinal(targetEntity, StatmodTopics.SPELL, [uint32(0), 0, 0, 0, 0]);
  }
}
