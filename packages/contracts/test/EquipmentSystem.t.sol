// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { commonSystem } from "../src/namespaces/common/codegen/systems/CommonSystemLib.sol";
import { equipmentSystem, EquipmentSystemLib } from "../src/namespaces/equipment/codegen/systems/EquipmentSystemLib.sol";
import { effectTemplateSystem, EffectTemplateData } from "../src/namespaces/effect/codegen/systems/EffectTemplateSystemLib.sol";
import { _cycleEquipmentSystemIds } from "../src/namespaces/cycle/CycleCombatRewardSystem.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibGuise } from "../src/namespaces/root/guise/LibGuise.sol";
import { LibSOFAccess } from "../src/namespaces/evefrontier/LibSOFAccess.sol";
import { entitySystem } from "../src/namespaces/evefrontier/codegen/systems/EntitySystemLib.sol";
import { Name, OwnedBy } from "../src/namespaces/common/codegen/index.sol";
import { EquipmentTypeComponent, SlotEquipment, SlotAllowedType } from "../src/namespaces/equipment/codegen/index.sol";
import { makeEffectTemplate } from "../src/namespaces/effect/makeEffectTemplate.sol";
import { StatmodTopics } from "../src/namespaces/statmod/StatmodTopic.sol";
import { EquipmentTypes, EquipmentType } from "../src/namespaces/equipment/EquipmentType.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { Idx_SlotEquipment_EquipmentEntity } from "../src/namespaces/equipment/codegen/idxs/Idx_SlotEquipment_EquipmentEntity.sol";

contract EquipmentSystemTest is BaseTest {
  bytes32 playerEntity;

  // equipment slots
  bytes32 armorSlot;
  bytes32 mainHandSlot;
  bytes32 offHandSlot;
  // equipment entities
  bytes32 armor;
  bytes32 sword1;
  bytes32 sword2;
  bytes32 shield;
  bytes32 miscThing;

  function setUp() public virtual override {
    super.setUp();

    _addToScope("test", equipmentSystem.toResourceId());

    vm.startPrank(deployer);
    playerEntity = LibSOFClass.instantiate("test", alice);

    armor = LibSOFClass.instantiate("test2", deployer);
    sword1 = LibSOFClass.instantiate("test2", deployer);
    sword2 = LibSOFClass.instantiate("test2", deployer);
    shield = LibSOFClass.instantiate("test2", deployer);
    miscThing = LibSOFClass.instantiate("test2", deployer);
    vm.stopPrank();

    // create equipment slots
    ResourceId[] memory scopedSystemIds = new ResourceId[](1);
    scopedSystemIds[0] = scopedSystemId;
    armorSlot = scopedSystemMock.equipment__createEquipmentSlot(
      playerEntity,
      "armorSlot",
      EquipmentTypes.CLOTHING,
      scopedSystemIds
    );

    mainHandSlot = scopedSystemMock.equipment__createEquipmentSlot(
      playerEntity,
      "mainHandSlot",
      EquipmentTypes.WEAPON,
      scopedSystemIds
    );

    EquipmentType[] memory offHandSlots = new EquipmentType[](2);
    offHandSlots[0] = EquipmentTypes.WEAPON;
    offHandSlots[1] = EquipmentTypes.SHIELD;
    offHandSlot = scopedSystemMock.equipment__createEquipmentSlot(
      playerEntity,
      "offHandSlot",
      offHandSlots,
      scopedSystemIds
    );

    // init equipment
    EquipmentTypeComponent.set(armor, EquipmentTypes.CLOTHING);
    scopedSystemMock.effect__setEffectTemplate(
      armor,
      makeEffectTemplate(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.PHYSICAL, 40)
    );

    EquipmentTypeComponent.set(sword1, EquipmentTypes.WEAPON);
    scopedSystemMock.effect__setEffectTemplate(
      sword1,
      makeEffectTemplate(
        StatmodTopics.ATTACK,
        StatmodOp.MUL,
        EleStat.PHYSICAL,
        100,
        StatmodTopics.ATTACK,
        StatmodOp.MUL,
        EleStat.FIRE,
        100
      )
    );

    EquipmentTypeComponent.set(sword2, EquipmentTypes.WEAPON);
    scopedSystemMock.effect__setEffectTemplate(
      sword2,
      makeEffectTemplate(
        StatmodTopics.ATTACK,
        StatmodOp.ADD,
        EleStat.FIRE,
        100,
        StatmodTopics.ATTACK,
        StatmodOp.MUL,
        EleStat.FIRE,
        100
      )
    );

    EquipmentTypeComponent.set(shield, EquipmentTypes.SHIELD);
    scopedSystemMock.effect__setEffectTemplate(
      shield,
      makeEffectTemplate(
        StatmodTopics.RESISTANCE,
        StatmodOp.ADD,
        EleStat.PHYSICAL,
        40,
        StatmodTopics.RESISTANCE,
        StatmodOp.ADD,
        EleStat.FIRE,
        40
      )
    );
  }

  function testCreateEquipmentSlot() public {
    // test that setUp correctly created the slots
    assertEq(OwnedBy.get(armorSlot), playerEntity);
    assertEq(OwnedBy.get(mainHandSlot), playerEntity);
    assertEq(OwnedBy.get(offHandSlot), playerEntity);

    assertTrue(SlotAllowedType.get(armorSlot, EquipmentTypes.CLOTHING));
    assertTrue(SlotAllowedType.get(mainHandSlot, EquipmentTypes.WEAPON));
    assertTrue(SlotAllowedType.get(offHandSlot, EquipmentTypes.WEAPON));
    assertTrue(SlotAllowedType.get(offHandSlot, EquipmentTypes.SHIELD));

    // test access control
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, playerEntity, emptySystemId)
    );
    emptySystemMock.equipment__createEquipmentSlot(
      playerEntity,
      "mainHandSlot",
      EquipmentTypes.WEAPON,
      new ResourceId[](0)
    );

    vm.startPrank(bob);

    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, playerEntity, bob));
    world.equipment__createEquipmentSlot(playerEntity, "mainHandSlot", EquipmentTypes.WEAPON, new ResourceId[](0));

    vm.stopPrank();
  }

  function testRevertUnscoped() public {
    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, playerEntity, emptySystemId)
    );
    emptySystemMock.equipment__equip(playerEntity, armorSlot, armor);

    _addToScope("test", emptySystemId);

    vm.expectRevert(
      abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, armorSlot, emptySystemId)
    );
    emptySystemMock.equipment__equip(playerEntity, armorSlot, armor);

    _addToScope("equipment_slot", emptySystemId);

    vm.expectRevert(abi.encodeWithSelector(SmartObjectFramework.SOF_UnscopedSystemCall.selector, armor, emptySystemId));
    emptySystemMock.equipment__equip(playerEntity, armorSlot, armor);

    _addToScope("test2", emptySystemId);

    emptySystemMock.equipment__equip(playerEntity, armorSlot, armor);
  }

  function testRevertAccessDenied() public {
    vm.prank(bob);
    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, playerEntity, bob));
    world.equipment__equip(playerEntity, armorSlot, miscThing);

    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.SOFAccess_AccessDenied.selector, armorSlot, alice));
    world.equipment__equip(playerEntity, armorSlot, miscThing);
  }

  // TODO test that effects are applied/removed correctly

  function testEquipRevertInvalidEquipmentType() public {
    vm.expectRevert(
      abi.encodeWithSelector(EquipmentSystemLib.EquipmentSystem_InvalidEquipmentType.selector, miscThing)
    );
    scopedSystemMock.equipment__equip(playerEntity, armorSlot, miscThing);
  }

  function testEquipRevertSlotNotAllowedForPrototype() public {
    vm.expectRevert(
      abi.encodeWithSelector(
        EquipmentSystemLib.EquipmentSystem_SlotNotAllowedForType.selector,
        armorSlot,
        EquipmentTypes.WEAPON,
        sword1
      )
    );
    scopedSystemMock.equipment__equip(playerEntity, armorSlot, sword1);
  }

  function testEquipRevertEquipmentEntityAlreadyEquipped() public {
    scopedSystemMock.equipment__equip(playerEntity, mainHandSlot, sword1);

    vm.expectRevert(
      abi.encodeWithSelector(EquipmentSystemLib.EquipmentSystem_EquipmentEntityAlreadyEquipped.selector, sword1)
    );
    scopedSystemMock.equipment__equip(playerEntity, offHandSlot, sword1);
  }

  function testEquipUnequip() public {
    scopedSystemMock.equipment__equip(playerEntity, armorSlot, armor);
    assertEq(SlotEquipment.get(armorSlot), armor);
    (bool _has, uint40 _index) = Idx_SlotEquipment_EquipmentEntity.has(armorSlot);
    assertTrue(_has);
    assertEq(_index, 0);
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(armor, _index), armorSlot);

    scopedSystemMock.equipment__unequip(playerEntity, armorSlot);
    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    (_has, _index) = Idx_SlotEquipment_EquipmentEntity.has(armorSlot);
    assertFalse(_has);
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
  }

  function testEquipUnequipSeveralSlots() public {
    scopedSystemMock.equipment__equip(playerEntity, armorSlot, armor);
    scopedSystemMock.equipment__equip(playerEntity, mainHandSlot, sword1);
    scopedSystemMock.equipment__equip(playerEntity, offHandSlot, sword2);

    assertEq(SlotEquipment.get(armorSlot), armor);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(armor, 0), armorSlot);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword1, 0), mainHandSlot);
    assertEq(SlotEquipment.get(offHandSlot), sword2);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword2, 0), offHandSlot);

    scopedSystemMock.equipment__unequip(playerEntity, armorSlot);

    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword1, 0), mainHandSlot);
    assertEq(SlotEquipment.get(offHandSlot), sword2);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword2, 0), offHandSlot);

    scopedSystemMock.equipment__unequip(playerEntity, offHandSlot);

    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword1, 0), mainHandSlot);
    assertEq(SlotEquipment.get(offHandSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(sword2), 0);

    scopedSystemMock.equipment__unequip(playerEntity, mainHandSlot);

    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
    assertEq(SlotEquipment.get(mainHandSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(sword1), 0);
    assertEq(SlotEquipment.get(offHandSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(sword2), 0);
  }

  function testReequipSameSlotSameEntity() public {
    scopedSystemMock.equipment__equip(playerEntity, mainHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    scopedSystemMock.equipment__equip(playerEntity, mainHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
  }

  function testReequipSameSlotDifferentEntities() public {
    scopedSystemMock.equipment__equip(playerEntity, offHandSlot, sword1);
    assertEq(SlotEquipment.get(offHandSlot), sword1);
    scopedSystemMock.equipment__equip(playerEntity, offHandSlot, shield);
    assertEq(SlotEquipment.get(offHandSlot), shield);
    scopedSystemMock.equipment__equip(playerEntity, offHandSlot, sword2);
    assertEq(SlotEquipment.get(offHandSlot), sword2);
  }

  function testReequipDifferentSlotsSameEntity() public {
    scopedSystemMock.equipment__equip(playerEntity, mainHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(SlotEquipment.get(offHandSlot), bytes32(0));

    scopedSystemMock.equipment__unequip(playerEntity, mainHandSlot);
    scopedSystemMock.equipment__equip(playerEntity, offHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), bytes32(0));
    assertEq(SlotEquipment.get(offHandSlot), sword1);
  }

  // TODO the lack of any enumeration of equipment slots is ugly if they're needed onchain, this hack only works in tests
  function _findCycleArmorSlot(bytes32 cycleEntity) internal view returns (bytes32 cycleArmorSlot) {
    for (uint256 i = uint256(cycleEntity); i < uint256(cycleEntity) + 100; i++) {
      bytes32 entity = bytes32(i);
      if (
        keccak256(bytes(Name.get(entity))) == keccak256("Body") &&
        OwnedBy.get(entity) == cycleEntity &&
        SlotAllowedType.get(entity, EquipmentTypes.CLOTHING)
      ) {
        cycleArmorSlot = entity;
        return cycleArmorSlot;
      }
    }
    revert("No armor slot found");
  }

  function testCycleEquipment() public {
    bytes32 guiseEntity = LibGuise.getGuiseEntity("Warrior");
    vm.prank(alice);
    (, bytes32 cycleEntity) = world.wanderer__spawnWanderer(guiseEntity);

    vm.startPrank(deployer);
    commonSystem.setOwnedBy(armor, cycleEntity);
    entitySystem.addToScope(uint256(armor), _cycleEquipmentSystemIds());
    vm.stopPrank();

    bytes32 cycleArmorSlot = _findCycleArmorSlot(cycleEntity);

    vm.prank(alice);
    world.cycle__equip(cycleEntity, cycleArmorSlot, armor);
  }
}
