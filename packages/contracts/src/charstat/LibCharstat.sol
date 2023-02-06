// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { Statmod, Element, EL_L } from "../statmod/Statmod.sol";
import { Topics } from "./Topics.sol";
import { LibExperience, PStat, PS_L } from "./LibExperience.sol";
import { LifeCurrentComponent, ID as LifeCurrentComponentID } from "./LifeCurrentComponent.sol";
import { ManaCurrentComponent, ID as ManaCurrentComponentID } from "./ManaCurrentComponent.sol";

library LibCharstat {
  using Statmod for Statmod.Self;
  using LibExperience for LibExperience.Self;

  struct Self {
    Statmod.Self statmod;
    LibExperience.Self exp;
    LifeCurrentComponent lifeCComp;
    ManaCurrentComponent manaCComp;
    uint256 targetEntity;
  }

  function __construct(IUint256Component components, uint256 targetEntity) internal view returns (Self memory) {
    return
      Self({
        statmod: Statmod.__construct(components, targetEntity),
        exp: LibExperience.__construct(components, targetEntity),
        lifeCComp: LifeCurrentComponent(getAddressById(components, LifeCurrentComponentID)),
        manaCComp: ManaCurrentComponent(getAddressById(components, ManaCurrentComponentID)),
        targetEntity: targetEntity
      });
  }

  // ========== PRIMARY STATS (strength, arcana, dexterity) ==========
  function getBasePStat(Self memory __self, PStat pstatIndex) internal view returns (uint32) {
    if (__self.exp.hasExp()) {
      // if entity uses exp component, use that for primary stats
      return __self.exp.getPStat(pstatIndex);
    } else {
      // otherwise try a special statmod
      return __self.statmod.getValuesFinal(Topics.LEVEL.toEntity(), 0);
    }
  }

  function getPStat(Self memory __self, PStat pstatIndex) internal view returns (uint32) {
    uint32 baseValue = getBasePStat(__self, pstatIndex);

    return __self.statmod.getValuesFinal(Topics.PSTAT()[uint256(pstatIndex)].toEntity(), baseValue);
  }

  function getPStats(Self memory __self) internal view returns (uint32[PS_L] memory pstats) {
    for (uint256 i; i < PS_L; i++) {
      pstats[i] = getPStat(__self, PStat(i));
    }
    return pstats;
  }

  // ========== ATTRIBUTES ==========
  function getLife(Self memory __self) internal view returns (uint32) {
    uint32 strength = getPStat(__self, PStat.STRENGTH);
    uint32 baseValue = 2 + 2 * strength;

    return __self.statmod.getValuesFinal(Topics.LIFE.toEntity(), baseValue);
  }

  function getMana(Self memory __self) internal view returns (uint32) {
    uint32 arcana = getPStat(__self, PStat.ARCANA);
    uint32 baseValue = 4 * arcana;

    return __self.statmod.getValuesFinal(Topics.MANA.toEntity(), baseValue);
  }

  function getFortune(Self memory __self) internal view returns (uint32) {
    return __self.statmod.getValuesFinal(Topics.FORTUNE.toEntity(), 0);
  }

  function getConnection(Self memory __self) internal view returns (uint32) {
    return __self.statmod.getValuesFinal(Topics.CONNECTION.toEntity(), 0);
  }

  function getLifeRegen(Self memory __self) internal view returns (uint32) {
    return __self.statmod.getValuesFinal(Topics.LIFE_GAINED_PER_TURN.toEntity(), 0);
  }

  function getManaRegen(Self memory __self) internal view returns (uint32) {
    return __self.statmod.getValuesFinal(Topics.MANA_GAINED_PER_TURN.toEntity(), 0);
  }

  // ========== ELEMENTAL ==========
  function getAttack(Self memory __self) internal view returns (uint32[EL_L] memory) {
    uint32 strength = getPStat(__self, PStat.STRENGTH);
    // strength increases physical base attack damage
    uint32[EL_L] memory baseValues = [uint32(0), strength / 2 + 1, 0, 0, 0];

    return __self.statmod.getValuesElementalFinal(Topics.ATTACK.toEntity(), baseValues);
  }

  function getSpell(Self memory __self, uint32[EL_L] memory baseValues) internal view returns (uint32[EL_L] memory) {
    uint32 arcana = getPStat(__self, PStat.ARCANA);
    // arcana increases non-zero base spell damage
    for (uint256 i; i < EL_L; i++) {
      if (baseValues[i] > 0) {
        // TODO u sure it's fine to modify in-place like that?
        baseValues[i] += arcana;
      }
    }

    return __self.statmod.getValuesElementalFinal(Topics.SPELL.toEntity(), baseValues);
  }

  function getResistance(Self memory __self) internal view returns (uint32[EL_L] memory) {
    uint32 dexterity = getPStat(__self, PStat.DEXTERITY);
    // dexterity increases base physical resistance
    uint32[EL_L] memory baseValues = [uint32((dexterity / 4) * 4), 0, 0, 0, 0];

    return __self.statmod.getValuesElementalFinal(Topics.SPELL.toEntity(), baseValues);
  }

  // ========== CURRENTS ==========
  function getLifeCurrent(Self memory __self) internal view returns (uint32) {
    uint32 lifeMax = getLife(__self);
    uint32 lifeCurrent = __self.lifeCComp.getValue(__self.targetEntity);
    if (lifeCurrent > lifeMax) {
      return lifeMax;
    } else {
      return uint32(lifeCurrent);
    }
  }

  function setLifeCurrent(Self memory __self, uint32 value) internal {
    __self.lifeCComp.set(__self.targetEntity, value);
  }

  function getManaCurrent(Self memory __self) internal view returns (uint32) {
    uint32 manaMax = getMana(__self);
    uint32 manaCurrent = __self.manaCComp.getValue(__self.targetEntity);
    if (manaCurrent > manaMax) {
      return manaMax;
    } else {
      return uint32(manaCurrent);
    }
  }

  function setManaCurrent(Self memory __self, uint32 value) internal {
    __self.manaCComp.set(__self.targetEntity, value);
  }

  /**
   * @dev Set currents to max values
   */
  function setFullCurrents(Self memory __self) internal {
    setLifeCurrent(__self, getLife(__self));
    setManaCurrent(__self, getMana(__self));
  }

  // ========== ROUND DAMAGE ==========
  function getRoundDamage(Self memory __self) internal view returns (uint32[EL_L] memory) {
    return __self.statmod.getValuesElementalFinal(Topics.SPELL.toEntity(), [uint32(0), 0, 0, 0, 0]);
  }
}
