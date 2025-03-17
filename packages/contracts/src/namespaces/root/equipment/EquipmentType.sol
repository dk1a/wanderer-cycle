// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

type EquipmentType is bytes32;

library EquipmentTypes {
  EquipmentType constant WEAPON = EquipmentType.wrap("Weapon");
  EquipmentType constant SHIELD = EquipmentType.wrap("Shield");
  EquipmentType constant HAT = EquipmentType.wrap("Hat");
  EquipmentType constant CLOTHING = EquipmentType.wrap("Clothing");
  EquipmentType constant GLOVES = EquipmentType.wrap("Gloves");
  EquipmentType constant PANTS = EquipmentType.wrap("Pants");
  EquipmentType constant BOOTS = EquipmentType.wrap("Boots");
  EquipmentType constant AMULET = EquipmentType.wrap("Amulet");
  EquipmentType constant RING = EquipmentType.wrap("Ring");
}

using { eq as ==, ne as != } for EquipmentType global;

function eq(EquipmentType a, EquipmentType b) pure returns (bool) {
  return EquipmentType.unwrap(a) == EquipmentType.unwrap(b);
}

function ne(EquipmentType a, EquipmentType b) pure returns (bool) {
  return EquipmentType.unwrap(a) != EquipmentType.unwrap(b);
}
