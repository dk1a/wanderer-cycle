// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { World } from "solecs/World.sol";

import {
  EquipmentAction,
  EquipmentSystem,
  ID as EquipmentSystemID
} from "../EquipmentSystem.sol";
import { EquipmentComponent, ID as EquipmentComponentID } from "../EquipmentComponent.sol";
import { EquipmentTypeComponent, ID as EquipmentTypeComponentID } from "../EquipmentTypeComponent.sol";
import { EquipmentSlotToTypesComponent, ID as EquipmentSlotToTypesComponentID } from "../EquipmentSlotToTypesComponent.sol";

import { LibEffectPrototype } from "../../effect/LibEffectPrototype.sol";
import { EffectPrototype, EffectStatmod, EffectRemovability } from "../../effect/EffectPrototypeComponent.sol";

import { _effectStatmods } from "../../effect/utils.sol";

contract EquipmentSystemTest is Test {
  EquipmentSystem equipmentSystem;

  EquipmentTypeComponent equipmentTypeComp;
  EquipmentSlotToTypesComponent equipmentSlotToTypesComp;
  EquipmentComponent equipmentComp;

  uint256 playerEntity = uint256(keccak256('playerEntity'));

  // equipment entities
  uint256 armor = uint256(keccak256('armor'));
  uint256 sword1 = uint256(keccak256('sword1'));
  uint256 sword2 = uint256(keccak256('sword2'));
  uint256 shield = uint256(keccak256('shield'));
  uint256 miscThing = uint256(keccak256('miscThing'));
  // equipment types
  uint256 armorType = uint256(keccak256('armorType'));
  uint256 weaponType = uint256(keccak256('weaponType'));
  uint256 shieldType = uint256(keccak256('shieldType'));
  // equipment slots
  uint256 armorSlot = uint256(keccak256('armorSlot'));
  uint256 mainHandSlot = uint256(keccak256('mainHandSlot'));
  uint256 offHandSlot = uint256(keccak256('offHandSlot'));

  function setUp() public virtual override {
    super.setUp();

    IUint256Component components = world.components();

    equipmentSystem = EquipmentSystem(getAddressById(world.systems(), EquipmentSystemID));

    equipmentTypeComp = EquipmentTypeComponent(getAddressById(components, EquipmentTypeComponentID));
    equipmentSlotToTypesComp = EquipmentSlotToTypesComponent(getAddressById(components, EquipmentSlotToTypesComponentID));
    equipmentComp = EquipmentComponent(getAddressById(components, EquipmentComponentID));

    equipmentTypeComp.set(armor, armorType);
    LibEffectPrototype.verifiedSet(components, armor, _effectProto(_effectStatmods(
      "+# physical resistance", 40
    )));

    equipmentTypeComp.set(sword1, weaponType);
    LibEffectPrototype.verifiedSet(components, sword1, _effectProto(_effectStatmods(
      "+# physical to attack", 100,
      "#% increased attack", 100
    )));

    equipmentTypeComp.set(sword2, weaponType);
    LibEffectPrototype.verifiedSet(components, sword2, _effectProto(_effectStatmods(
      "+# fire to attack", 100,
      "#% increased fire attack", 100
    )));

    equipmentTypeComp.set(shield, shieldType);
    LibEffectPrototype.verifiedSet(components, shield, _effectProto(_effectStatmods(
      "+# physical resistance", 40,
      "+# fire resistance", 40
    )));

    equipmentSlotToTypesComp.addItem(armorSlot, armorType);
    equipmentSlotToTypesComp.addItem(mainHandSlot, weaponType);
    equipmentSlotToTypesComp.addItem(offHandSlot, weaponType);
    equipmentSlotToTypesComp.addItem(offHandSlot, shieldType);
  }

  function _effectProto(EffectStatmod[] memory statmods) internal pure returns (EffectPrototype memory) {
    return EffectPrototype({
      removability: EffectRemovability.PERSISTENT,
      statmods: statmods
    });
  }

  // TODO test that effects are applied/removed correctly

  function testNoEquipInvalidType() public {
    vm.expectRevert(EquipmentSystem.EquipmentSystem__InvalidEquipmentType.selector);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, miscThing, playerEntity);
  }

  function testNoEquipInvalidSlot() public {
    vm.expectRevert(EquipmentSystem.EquipmentSystem__InvalidEquipmentSlotForType.selector);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, sword1, playerEntity);
  }

  function testNoEquipAlreadyEquipped() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);

    vm.expectRevert(EquipmentSystem.EquipmentSystem__EquipmentEntityAlreadyEquipped.selector);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
  }

  function testEquipUnequip() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    assertEq(equipmentComp.getValue(armorSlot), armor);

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);
    assertFalse(equipmentComp.has(armorSlot));
  }

  function testEquipUnequipSeveralSlots() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);

    assertEq(equipmentComp.getValue(armorSlot), armor);
    assertEq(equipmentComp.getValue(mainHandSlot), sword1);
    assertEq(equipmentComp.getValue(offHandSlot), sword2);

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);

    assertFalse(equipmentComp.has(armorSlot));
    assertEq(equipmentComp.getValue(mainHandSlot), sword1);
    assertEq(equipmentComp.getValue(offHandSlot), sword2);

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, offHandSlot, 0, playerEntity);

    assertFalse(equipmentComp.has(armorSlot));
    assertEq(equipmentComp.getValue(mainHandSlot), sword1);
    assertFalse(equipmentComp.has(offHandSlot));

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    assertFalse(equipmentComp.has(armorSlot));
    assertFalse(equipmentComp.has(mainHandSlot));
    assertFalse(equipmentComp.has(offHandSlot));
  }

  function testReequipSameSlotSameEntity() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentComp.getValue(mainHandSlot), sword1);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentComp.getValue(mainHandSlot), sword1);
  }

  function testReequipSameSlotDifferentEntities() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertEq(equipmentComp.getValue(offHandSlot), sword1);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, shield, playerEntity);
    assertEq(equipmentComp.getValue(offHandSlot), shield);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);
    assertEq(equipmentComp.getValue(offHandSlot), sword2);
  }

  function testReequipSameEntityDifferentSlots() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentComp.getValue(mainHandSlot), sword1);
    assertFalse(equipmentComp.has(offHandSlot));

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertFalse(equipmentComp.has(mainHandSlot));
    assertEq(equipmentComp.getValue(offHandSlot), sword1);
  }
}