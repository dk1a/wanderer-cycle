// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";
import { BaseTest } from "./BaseTest.t.sol";

import { equipmentSystem, EquipmentSystemLib } from "../src/namespaces/equipment/codegen/systems/EquipmentSystemLib.sol";
import { effectTemplateSystem, EffectTemplateData } from "../src/namespaces/effect/codegen/systems/EffectTemplateSystemLib.sol";
import { LibSOFClass } from "../src/namespaces/common/LibSOFClass.sol";
import { LibSOFAccess } from "../src/namespaces/evefrontier/LibSOFAccess.sol";
import { OwnedBy } from "../src/namespaces/common/codegen/index.sol";
import { EquipmentTypeComponent, SlotEquipment, SlotAllowedType } from "../src/namespaces/equipment/codegen/index.sol";
import { makeEffectTemplate } from "../src/namespaces/effect/makeEffectTemplate.sol";
import { StatmodTopics } from "../src/namespaces/statmod/StatmodTopic.sol";
import { EquipmentTypes, EquipmentType } from "../src/namespaces/equipment/EquipmentType.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { Idx_SlotEquipment_EquipmentEntity } from "../src/namespaces/equipment/codegen/idxs/Idx_SlotEquipment_EquipmentEntity.sol";

contract EquipmentSystemTest is BaseTest {
  bytes32 playerEntity;

  // equipment entities
  bytes32 armor = keccak256("armor");
  bytes32 sword1 = keccak256("sword1");
  bytes32 sword2 = keccak256("sword2");
  bytes32 shield = keccak256("shield");
  bytes32 miscThing = keccak256("miscThing");
  // equipment slots
  bytes32 armorSlot;
  bytes32 mainHandSlot;
  bytes32 offHandSlot;

  function setUp() public virtual override {
    super.setUp();

    vm.startPrank(deployer);
    playerEntity = LibSOFClass.instantiate("test", deployer);
    vm.stopPrank();

    armorSlot = scopedSystemMock.equipment__createEquipmentSlot(playerEntity, "armorSlot", EquipmentTypes.CLOTHING);

    mainHandSlot = scopedSystemMock.equipment__createEquipmentSlot(playerEntity, "mainHandSlot", EquipmentTypes.WEAPON);

    EquipmentType[] memory offHandSlots = new EquipmentType[](2);
    offHandSlots[0] = EquipmentTypes.WEAPON;
    offHandSlots[1] = EquipmentTypes.SHIELD;
    offHandSlot = scopedSystemMock.equipment__createEquipmentSlot(playerEntity, "offHandSlot", offHandSlots);

    // init equipment
    EquipmentTypeComponent.set(armor, EquipmentTypes.CLOTHING);
    effectTemplateSystem.setEffectTemplate(
      armor,
      makeEffectTemplate(StatmodTopics.RESISTANCE, StatmodOp.ADD, EleStat.PHYSICAL, 40)
    );

    EquipmentTypeComponent.set(sword1, EquipmentTypes.WEAPON);
    effectTemplateSystem.setEffectTemplate(
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
    effectTemplateSystem.setEffectTemplate(
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
    effectTemplateSystem.setEffectTemplate(
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
    emptySystemMock.equipment__createEquipmentSlot(playerEntity, "mainHandSlot", EquipmentTypes.WEAPON);

    vm.startPrank(bob);

    vm.expectRevert(abi.encodeWithSelector(LibSOFAccess.LibSOFAccess_AccessDenied.selector, playerEntity, bob));
    world.equipment__createEquipmentSlot(playerEntity, "mainHandSlot", EquipmentTypes.WEAPON);

    vm.stopPrank();
  }

  // TODO test that effects are applied/removed correctly

  function testEquipRevertInvalidEquipmentType() public {
    vm.expectRevert(
      abi.encodeWithSelector(EquipmentSystemLib.EquipmentSystem_InvalidEquipmentType.selector, miscThing)
    );
    equipmentSystem.equip(playerEntity, armorSlot, miscThing);
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
    equipmentSystem.equip(playerEntity, armorSlot, sword1);
  }

  function testEquipRevertEquipmentEntityAlreadyEquipped() public {
    equipmentSystem.equip(playerEntity, mainHandSlot, sword1);

    vm.expectRevert(
      abi.encodeWithSelector(EquipmentSystemLib.EquipmentSystem_EquipmentEntityAlreadyEquipped.selector, sword1)
    );
    equipmentSystem.equip(playerEntity, offHandSlot, sword1);
  }

  function testEquipUnequip() public {
    equipmentSystem.equip(playerEntity, armorSlot, armor);
    assertEq(SlotEquipment.get(armorSlot), armor);
    (bool _has, uint40 _index) = Idx_SlotEquipment_EquipmentEntity.has(armorSlot);
    assertTrue(_has);
    assertEq(_index, 0);
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(armor, _index), armorSlot);

    equipmentSystem.unequip(playerEntity, armorSlot);
    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    (_has, _index) = Idx_SlotEquipment_EquipmentEntity.has(armorSlot);
    assertFalse(_has);
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
  }

  function testEquipUnequipSeveralSlots() public {
    equipmentSystem.equip(playerEntity, armorSlot, armor);
    equipmentSystem.equip(playerEntity, mainHandSlot, sword1);
    equipmentSystem.equip(playerEntity, offHandSlot, sword2);

    assertEq(SlotEquipment.get(armorSlot), armor);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(armor, 0), armorSlot);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword1, 0), mainHandSlot);
    assertEq(SlotEquipment.get(offHandSlot), sword2);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword2, 0), offHandSlot);

    equipmentSystem.unequip(playerEntity, armorSlot);

    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword1, 0), mainHandSlot);
    assertEq(SlotEquipment.get(offHandSlot), sword2);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword2, 0), offHandSlot);

    equipmentSystem.unequip(playerEntity, offHandSlot);

    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(Idx_SlotEquipment_EquipmentEntity.get(sword1, 0), mainHandSlot);
    assertEq(SlotEquipment.get(offHandSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(sword2), 0);

    equipmentSystem.unequip(playerEntity, mainHandSlot);

    assertEq(SlotEquipment.get(armorSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(armor), 0);
    assertEq(SlotEquipment.get(mainHandSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(sword1), 0);
    assertEq(SlotEquipment.get(offHandSlot), bytes32(0));
    assertEq(Idx_SlotEquipment_EquipmentEntity.length(sword2), 0);
  }

  function testReequipSameSlotSameEntity() public {
    equipmentSystem.equip(playerEntity, mainHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    equipmentSystem.equip(playerEntity, mainHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
  }

  function testReequipSameSlotDifferentEntities() public {
    equipmentSystem.equip(playerEntity, offHandSlot, sword1);
    assertEq(SlotEquipment.get(offHandSlot), sword1);
    equipmentSystem.equip(playerEntity, offHandSlot, shield);
    assertEq(SlotEquipment.get(offHandSlot), shield);
    equipmentSystem.equip(playerEntity, offHandSlot, sword2);
    assertEq(SlotEquipment.get(offHandSlot), sword2);
  }

  function testReequipDifferentSlotsSameEntity() public {
    equipmentSystem.equip(playerEntity, mainHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), sword1);
    assertEq(SlotEquipment.get(offHandSlot), bytes32(0));

    equipmentSystem.unequip(playerEntity, mainHandSlot);
    equipmentSystem.equip(playerEntity, offHandSlot, sword1);
    assertEq(SlotEquipment.get(mainHandSlot), bytes32(0));
    assertEq(SlotEquipment.get(offHandSlot), sword1);
  }
}
