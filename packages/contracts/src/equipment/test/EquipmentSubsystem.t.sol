// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";

import { EquipmentSubsystem, EquipmentAction } from "../EquipmentSubsystem.sol";
import { LibEffectPrototype } from "../../effect/LibEffectPrototype.sol";
import { EffectPrototype, EffectStatmod, EffectRemovability } from "../../effect/EffectPrototypeComponent.sol";
import { getEquipmentProtoEntity } from "../EquipmentPrototypeComponent.sol";
import { Topics, Op, Element } from "../../charstat/Topics.sol";
import { effectStatmods } from "../../effect/effectStatmods.sol";

contract EquipmentSubsystemTest is BaseTest {
  uint256 playerEntity = uint256(keccak256('playerEntity'));

  // equipment entities
  uint256 armor = uint256(keccak256('armor'));
  uint256 sword1 = uint256(keccak256('sword1'));
  uint256 sword2 = uint256(keccak256('sword2'));
  uint256 shield = uint256(keccak256('shield'));
  uint256 miscThing = uint256(keccak256('miscThing'));
  // equipment prototypes
  uint256 clothingProtoEntity = getEquipmentProtoEntity("Clothing");
  uint256 weaponProtoEntity = getEquipmentProtoEntity("Weapon");
  uint256 shieldProtoEntity = getEquipmentProtoEntity("Shield");
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
    LibEffectPrototype.verifiedSet(components, armor, _effectProto(effectStatmods(
      Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 40
    )));

    fromPrototypeComponent.set(sword1, weaponProtoEntity);
    LibEffectPrototype.verifiedSet(components, sword1, _effectProto(effectStatmods(
      Topics.ATTACK, Op.ADD, Element.PHYSICAL, 100,
      Topics.ATTACK, Op.MUL, Element.ALL, 100
    )));

    fromPrototypeComponent.set(sword2, weaponProtoEntity);
    LibEffectPrototype.verifiedSet(components, sword2, _effectProto(effectStatmods(
      Topics.ATTACK, Op.ADD, Element.FIRE, 100,
      Topics.ATTACK, Op.MUL, Element.FIRE, 100
    )));

    fromPrototypeComponent.set(shield, shieldProtoEntity);
    LibEffectPrototype.verifiedSet(components, shield, _effectProto(effectStatmods(
      Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 40,
      Topics.RESISTANCE, Op.ADD, Element.FIRE, 40
    )));

    // non-equipment prototype
    fromPrototypeComponent.set(miscThing, miscThing);
  }

  function _effectProto(EffectStatmod[] memory statmods) internal pure returns (EffectPrototype memory) {
    return EffectPrototype({
      removability: EffectRemovability.PERSISTENT,
      statmods: statmods
    });
  }

  // TODO test that effects are applied/removed correctly

  function testNoEquipInvalidPrototype() public {
    vm.expectRevert(EquipmentSubsystem.EquipmentSubsystem__InvalidEquipmentPrototype.selector);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, miscThing, playerEntity);
  }

  function testNoEquipInvalidSlot() public {
    vm.expectRevert(EquipmentSubsystem.EquipmentSubsystem__SlotNotAllowedForPrototype.selector);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, sword1, playerEntity);
  }

  function testNoEquipAlreadyEquipped() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);

    vm.expectRevert(EquipmentSubsystem.EquipmentSubsystem__EquipmentEntityAlreadyEquipped.selector);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
  }

  function testEquipUnequip() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    assertEq(equipmentSlotComponent.getValue(armorSlot), armor);

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);
    assertFalse(equipmentSlotComponent.has(armorSlot));
  }

  function testEquipUnequipSeveralSlots() public {
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

  function testReequipSameSlotSameEntity() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
  }

  function testReequipSameSlotDifferentEntities() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword1);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, shield, playerEntity);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), shield);
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword2);
  }

  function testReequipSameEntityDifferentSlots() public {
    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(equipmentSlotComponent.getValue(mainHandSlot), sword1);
    assertFalse(equipmentSlotComponent.has(offHandSlot));

    equipmentSubsystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    equipmentSubsystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertFalse(equipmentSlotComponent.has(mainHandSlot));
    assertEq(equipmentSlotComponent.getValue(offHandSlot), sword1);
  }
}