// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import { EquipmentSubsystem, EquipmentAction } from "../EquipmentSubsystem.sol";
import { LibEffectPrototype } from "../../effect/LibEffectPrototype.sol";
import { EffectPrototype, EffectRemovability } from "../../effect/EffectPrototypeComponent.sol";
import { EquipmentPrototypes } from "../EquipmentPrototypes.sol";
import { Topics, Op, Element } from "../../charstat/Topics.sol";
import { makeEffectPrototype } from "../../effect/makeEffectPrototype.sol";

contract EquipmentSubsystemTest is BaseTest {
  uint256 playerEntity = uint256(keccak256('playerEntity'));

  // equipment entities
  uint256 armor = uint256(keccak256('armor'));
  uint256 sword1 = uint256(keccak256('sword1'));
  uint256 sword2 = uint256(keccak256('sword2'));
  uint256 shield = uint256(keccak256('shield'));
  uint256 miscThing = uint256(keccak256('miscThing'));
  // equipment prototypes
  uint256 clothingProtoEntity = EquipmentPrototypes.CLOTHING;
  uint256 weaponProtoEntity = EquipmentPrototypes.WEAPON;
  uint256 shieldProtoEntity = EquipmentPrototypes.SHIELD;
  // equipment slots
  uint256 armorSlot = uint256(keccak256('armorSlot'));
  uint256 mainHandSlot = uint256(keccak256('mainHandSlot'));
  uint256 offHandSlot = uint256(keccak256('offHandSlot'));

  function setUp() public virtual override {
    super.setUp();

    IUint256Component components = world.components();

    // allow prototypes for slots
    equipmentSlotAllowedComponent.addItem(armorSlot, clothingProtoEntity);
    equipmentSlotAllowedComponent.addItem(mainHandSlot, weaponProtoEntity);
    equipmentSlotAllowedComponent.addItem(offHandSlot, weaponProtoEntity);
    equipmentSlotAllowedComponent.addItem(offHandSlot, shieldProtoEntity);

    // init equipment
    fromPrototypeComponent.set(armor, clothingProtoEntity);
    LibEffectPrototype.verifiedSet(components, armor, makeEffectPrototype(
      EffectRemovability.PERSISTENT,
      Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 40
    ));

    fromPrototypeComponent.set(sword1, weaponProtoEntity);
    LibEffectPrototype.verifiedSet(components, sword1, makeEffectPrototype(
      EffectRemovability.PERSISTENT,
      Topics.ATTACK, Op.MUL, Element.ALL, 100
    ));

    fromPrototypeComponent.set(sword2, weaponProtoEntity);
    LibEffectPrototype.verifiedSet(components, sword2, makeEffectPrototype(
      EffectRemovability.PERSISTENT,
      Topics.ATTACK, Op.ADD, Element.FIRE, 100,
      Topics.ATTACK, Op.MUL, Element.FIRE, 100
    ));

    fromPrototypeComponent.set(shield, shieldProtoEntity);
    LibEffectPrototype.verifiedSet(components, shield, makeEffectPrototype(
      EffectRemovability.PERSISTENT,
      Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 40,
      Topics.RESISTANCE, Op.ADD, Element.FIRE, 40
    ));

    // non-equipment prototype
    fromPrototypeComponent.set(miscThing, miscThing);
  }

  // TODO test that effects are applied/removed correctly

  function test_equip_revert_InvalidEquipmentPrototype() public {
    vm.expectRevert(EquipmentSubsystem.EquipmentSubsystem__InvalidEquipmentPrototype.selector);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, miscThing, playerEntity);
  }

  function test_equip_revert_SlotNotAllowedForPrototype() public {
    vm.expectRevert(EquipmentSubsystem.EquipmentSubsystem__SlotNotAllowedForPrototype.selector);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, sword1, playerEntity);
  }

  function test_equip_revert_EquipmentEntityAlreadyEquipped() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);

    vm.expectRevert(EquipmentSubsystem.EquipmentSubsystem__EquipmentEntityAlreadyEquipped.selector);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
  }

  function test_equipUnequip() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    assertEq(equipmentSlotComponent.getValue(armorSlot), armor);

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);
    assertFalse(equipmentSlotComponent.has(armorSlot));
  }

  function test_equipUnequip_severalSlots() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);

    assertEq(equipmentSlotComponent.getValue(armorSlot), armor);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword2);

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);

    assertFalse(equipmentSlotComponent.has(armorSlot));
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword2);

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, offHandSlot, 0, playerEntity);

    assertFalse(equipmentSlotComponent.has(armorSlot));
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    assertFalse(equipmentSlotComponent.has(offHandSlot));

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    assertFalse(equipmentSlotComponent.has(armorSlot));
    assertFalse(equipmentSlotComponent.has(mainHandSlot));
    assertFalse(equipmentSlotComponent.has(offHandSlot));
  }

  function test_reequip_sameSlot_sameEntity() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
  }

  function test_reequip_sameSlot_differentEntities() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword1);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, shield, playerEntity);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), shield);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword2);
  }

  function test_reequip_differentSlots_sameEntity() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    assertFalse(equipmentSlotComponent.has(offHandSlot));

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertFalse(equipmentSlotComponent.has(mainHandSlot));
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword1);
  }
}