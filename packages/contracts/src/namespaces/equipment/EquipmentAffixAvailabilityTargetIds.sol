// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixAvailabilityTargetId } from "../affix/types.sol";

library EquipmentAffixAvailabilityTargetIds {
  AffixAvailabilityTargetId constant WEAPON = AffixAvailabilityTargetId.wrap("eq:Weapon");
  AffixAvailabilityTargetId constant SHIELD = AffixAvailabilityTargetId.wrap("eq:Shield");
  AffixAvailabilityTargetId constant HAT = AffixAvailabilityTargetId.wrap("eq:Hat");
  AffixAvailabilityTargetId constant CLOTHING = AffixAvailabilityTargetId.wrap("eq:Clothing");
  AffixAvailabilityTargetId constant GLOVES = AffixAvailabilityTargetId.wrap("eq:Gloves");
  AffixAvailabilityTargetId constant PANTS = AffixAvailabilityTargetId.wrap("eq:Pants");
  AffixAvailabilityTargetId constant BOOTS = AffixAvailabilityTargetId.wrap("eq:Boots");
  AffixAvailabilityTargetId constant AMULET = AffixAvailabilityTargetId.wrap("eq:Amulet");
  AffixAvailabilityTargetId constant RING = AffixAvailabilityTargetId.wrap("eq:Ring");
}
