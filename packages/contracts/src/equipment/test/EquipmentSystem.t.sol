// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import { World } from "@latticexyz/solecs/src/World.sol";

import {
  EquipmentAction,
  EquipmentSystem,
  ID as EquipmentSystemID
} from "../EquipmentSystem.sol";
import { EquipmentSlotComponent, ID as EquipmentSlotComponentID } from "../EquipmentSlotComponent.sol";
import { EquipmentSlotAllowedComponent, ID as EquipmentSlotAllowedComponentID } from "../EquipmentSlotAllowedComponent.sol";
import { FromPrototypeComponent, ID as FromPrototypeComponentID } from "../../common/FromPrototypeComponent.sol";

import { LibEffectPrototype } from "../../effect/LibEffectPrototype.sol";
import { EffectPrototype, EffectStatmod, EffectRemovability } from "../../effect/EffectPrototypeComponent.sol";

import { getEquipmentProtoEntity } from "../EquipmentPrototypeComponent.sol";
import { Topics, Op, Element } from "../../charstat/Topics.sol";
import { effectStatmods } from "../../effect/effectStatmods.sol";

contract EquipmentSystemTest is Test {
  EquipmentSystem equipmentSystem;

  EquipmentSlotComponent slotComp;
  EquipmentSlotAllowedComponent slotAllowedComp;
  FromPrototypeComponent fromProtoComp;

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

    equipmentSystem = EquipmentSystem(getAddressById(world.systems(), EquipmentSystemID));

    slotComp = EquipmentSlotComponent(getAddressById(components, EquipmentSlotComponentID));
    slotAllowedComp = EquipmentSlotAllowedComponent(getAddressById(components, EquipmentSlotAllowedComponentID));
    fromProtoComp = FromPrototypeComponent(getAddressById(components, FromPrototypeComponentID));

    // allow prototypes for slots
    slotAllowedComp.addItem(armorSlot, clothingProtoEntity);
    slotAllowedComp.addItem(mainHandSlot, weaponProtoEntity);
    slotAllowedComp.addItem(offHandSlot, weaponProtoEntity);
    slotAllowedComp.addItem(offHandSlot, shieldProtoEntity);

    // init equipment
    fromProtoComp.set(armor, clothingProtoEntity);
    LibEffectPrototype.verifiedSet(components, armor, _effectProto(effectStatmods(
      Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 40
    )));

    fromProtoComp.set(sword1, weaponProtoEntity);
    LibEffectPrototype.verifiedSet(components, sword1, _effectProto(effectStatmods(
      Topics.ATTACK, Op.ADD, Element.PHYSICAL, 100,
      Topics.ATTACK, Op.MUL, Element.ALL, 100
    )));

    fromProtoComp.set(sword2, weaponProtoEntity);
    LibEffectPrototype.verifiedSet(components, sword2, _effectProto(effectStatmods(
      Topics.ATTACK, Op.ADD, Element.FIRE, 100,
      Topics.ATTACK, Op.MUL, Element.FIRE, 100
    )));

    fromProtoComp.set(shield, shieldProtoEntity);
    LibEffectPrototype.verifiedSet(components, shield, _effectProto(effectStatmods(
      Topics.RESISTANCE, Op.ADD, Element.PHYSICAL, 40,
      Topics.RESISTANCE, Op.ADD, Element.FIRE, 40
    )));

    // non-equipment prototype
    fromProtoComp.set(miscThing, miscThing);
  }

  function _effectProto(EffectStatmod[] memory statmods) internal pure returns (EffectPrototype memory) {
    return EffectPrototype({
      removability: EffectRemovability.PERSISTENT,
      statmods: statmods
    });
  }

  // TODO test that effects are applied/removed correctly

  function testNoEquipInvalidPrototype() public {
    vm.expectRevert(EquipmentSystem.EquipmentSystem__InvalidEquipmentPrototype.selector);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, miscThing, playerEntity);
  }

  function testNoEquipInvalidSlot() public {
    vm.expectRevert(EquipmentSystem.EquipmentSystem__SlotNotAllowedForPrototype.selector);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, sword1, playerEntity);
  }

  function testNoEquipAlreadyEquipped() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);

    vm.expectRevert(EquipmentSystem.EquipmentSystem__EquipmentEntityAlreadyEquipped.selector);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
  }

  function testEquipUnequip() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    assertEq(slotComp.getValue(armorSlot), armor);

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);
    assertFalse(slotComp.has(armorSlot));
  }

  function testEquipUnequipSeveralSlots() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, armorSlot, armor, playerEntity);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);

    assertEq(slotComp.getValue(armorSlot), armor);
    assertEq(slotComp.getValue(mainHandSlot), sword1);
    assertEq(slotComp.getValue(offHandSlot), sword2);

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, armorSlot, 0, playerEntity);

    assertFalse(slotComp.has(armorSlot));
    assertEq(slotComp.getValue(mainHandSlot), sword1);
    assertEq(slotComp.getValue(offHandSlot), sword2);

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, offHandSlot, 0, playerEntity);

    assertFalse(slotComp.has(armorSlot));
    assertEq(slotComp.getValue(mainHandSlot), sword1);
    assertFalse(slotComp.has(offHandSlot));

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    assertFalse(slotComp.has(armorSlot));
    assertFalse(slotComp.has(mainHandSlot));
    assertFalse(slotComp.has(offHandSlot));
  }

  function testReequipSameSlotSameEntity() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(slotComp.getValue(mainHandSlot), sword1);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(slotComp.getValue(mainHandSlot), sword1);
  }

  function testReequipSameSlotDifferentEntities() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertEq(slotComp.getValue(offHandSlot), sword1);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, shield, playerEntity);
    assertEq(slotComp.getValue(offHandSlot), shield);
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword2, playerEntity);
    assertEq(slotComp.getValue(offHandSlot), sword2);
  }

  function testReequipSameEntityDifferentSlots() public {
    equipmentSystem.executeTyped(EquipmentAction.EQUIP, mainHandSlot, sword1, playerEntity);
    assertEq(slotComp.getValue(mainHandSlot), sword1);
    assertFalse(slotComp.has(offHandSlot));

    equipmentSystem.executeTyped(EquipmentAction.UNEQUIP, mainHandSlot, 0, playerEntity);

    equipmentSystem.executeTyped(EquipmentAction.EQUIP, offHandSlot, sword1, playerEntity);
    assertFalse(slotComp.has(mainHandSlot));
    assertEq(slotComp.getValue(offHandSlot), sword1);
  }
}