// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BaseTest } from "./BaseTest.t.sol";
import { equipmentSystem, EquipmentSystemLib } from "../src/namespaces/equipment/codegen/systems/EquipmentSystemLib.sol";
import { effectTemplateSystem, EffectTemplateData } from "../src/namespaces/effect/codegen/systems/EffectTemplateSystemLib.sol";
import { EquipmentTypes, EquipmentType } from "../src/namespaces/equipment/EquipmentType.sol";
import { OwnedBy } from "../src/namespaces/common/codegen/index.sol";
import { EquipmentTypeComponent, SlotEquipment, SlotAllowedType } from "../src/namespaces/equipment/codegen/index.sol";
import { makeEffectTemplate } from "../src/namespaces/effect/makeEffectTemplate.sol";
import { StatmodTopics } from "../src/namespaces/statmod/StatmodTopic.sol";
import { StatmodOp, EleStat } from "../src/codegen/common.sol";
import { Idx_SlotEquipment_EquipmentEntity } from "../src/namespaces/equipment/codegen/idxs/Idx_SlotEquipment_EquipmentEntity.sol";

contract EquipmentSystemTest is BaseTest {
  bytes32 playerEntity = keccak256("playerEntity");

  // equipment entities
  bytes32 armor = keccak256("armor");
  bytes32 sword1 = keccak256("sword1");
  bytes32 sword2 = keccak256("sword2");
  bytes32 shield = keccak256("shield");
  bytes32 miscThing = keccak256("miscThing");
  // equipment slots
  bytes32 armorSlot = keccak256("armorSlot");
  bytes32 mainHandSlot = keccak256("mainHandSlot");
  bytes32 offHandSlot = keccak256("offHandSlot");

  function setUp() public virtual override {
    super.setUp();

    // make player own the slots
    OwnedBy.set(armorSlot, playerEntity);
    OwnedBy.set(mainHandSlot, playerEntity);
    OwnedBy.set(offHandSlot, playerEntity);

    // allow prototypes for slots
    SlotAllowedType.set(armorSlot, EquipmentTypes.CLOTHING, true);
    SlotAllowedType.set(mainHandSlot, EquipmentTypes.WEAPON, true);
    SlotAllowedType.set(offHandSlot, EquipmentTypes.WEAPON, true);
    SlotAllowedType.set(offHandSlot, EquipmentTypes.SHIELD, true);

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
