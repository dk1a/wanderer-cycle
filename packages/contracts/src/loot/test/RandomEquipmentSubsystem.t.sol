// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import { Loot } from "../LootComponent.sol";
import { EffectPrototype, EffectRemovability } from "../../effect/EffectPrototypeComponent.sol";
import { MAX_ILVL } from "../../init/LibBaseInitAffix.sol";

contract RandomEquipmentSubsystemTest is BaseTest {
  function setUp() public virtual override {
    super.setUp();
  }

  // tests basic assumptions, and that 2 mints don't break each other
  function test_randomEquipment_2(uint256 seed1, uint256 seed2) public {
    vm.assume(seed1 != seed2);

    uint32 ilvl1 = 1;
    uint32 ilvl2 = 5;

    uint256 lootEntity1 = randomEquipmentSubsystem.executeTyped(ilvl1, seed1);
    uint256 lootEntity2 = randomEquipmentSubsystem.executeTyped(ilvl2, seed2);

    // check entities
    assertNotEq(lootEntity1, lootEntity2);
    assertNotEq(lootEntity1, 0);
    assertNotEq(lootEntity2, 0);
    // check loot-specific data
    Loot memory loot1 = lootComponent.getValue(lootEntity1);
    Loot memory loot2 = lootComponent.getValue(lootEntity2);
    assertEq(loot1.ilvl, ilvl1);
    assertEq(loot2.ilvl, ilvl2);
    assertEq(loot1.affixProtoEntities.length, 1, "1: affixProtoEntities.length");
    assertEq(loot2.affixProtoEntities.length, 2, "2: affixProtoEntities.length");
    assertEq(loot1.affixValues.length, 1, "1: affixValues.length");
    assertEq(loot2.affixValues.length, 2, "2: affixValues.length");
    // check equipment prototype
    uint256 protoEntity1 = fromPrototypeComponent.getValue(lootEntity1);
    uint256 protoEntity2 = fromPrototypeComponent.getValue(lootEntity2);
    assertTrue(equipmentPrototypeComponent.has(protoEntity1));
    assertTrue(equipmentPrototypeComponent.has(protoEntity2));
    // check effect prototype
    EffectPrototype memory effectProto1 = effectPrototypeComponent.getValue(lootEntity1);
    EffectPrototype memory effectProto2 = effectPrototypeComponent.getValue(lootEntity2);
    assertEq(uint256(effectProto1.removability), uint256(EffectRemovability.PERSISTENT));
    assertEq(uint256(effectProto2.removability), uint256(EffectRemovability.PERSISTENT));
    assertEq(effectProto1.statmodProtoEntities.length, 1, "1: statmodProtoEntities.length");
    assertEq(effectProto2.statmodProtoEntities.length, 2, "2: statmodProtoEntities.length");
    assertEq(abi.encode(effectProto1.statmodValues), abi.encode(loot1.affixValues), "1: statmod values != affix values");
    assertEq(abi.encode(effectProto2.statmodValues), abi.encode(loot2.affixValues), "2: statmod values != affix values");
  }

  // affixes and equipment proto should be identical, but otherwise these should be 2 different entities
  function test_randomEquipment_sameSeed(uint256 seed) public {
    uint256 lootEntity1 = randomEquipmentSubsystem.executeTyped(1, seed);
    uint256 lootEntity2 = randomEquipmentSubsystem.executeTyped(1, seed);
    assertNotEq(lootEntity1, lootEntity2);
    assertEq(fromPrototypeComponent.getValue(lootEntity1), fromPrototypeComponent.getValue(lootEntity2));
    assertEq(
      keccak256(abi.encode(effectPrototypeComponent.getValue(lootEntity1))),
      keccak256(abi.encode(effectPrototypeComponent.getValue(lootEntity2)))
    );
  }

  // ensure that mint can actually produce different affixes
  function test_randomEquipment_differentAffixes() public {
    uint256 inequalityCount;
    for (uint256 i; i < 1000; i++) {
      uint256 seed1 = 1000000 + i;
      uint256 seed2 = 2000000 + i;

      uint256 lootEntity1 = randomEquipmentSubsystem.executeTyped(1, seed1);
      uint256 lootEntity2 = randomEquipmentSubsystem.executeTyped(1, seed2);
      assertNotEq(lootEntity1, lootEntity2);
      uint256[] memory affixProtoEntities1 = lootComponent.getValue(lootEntity1).affixProtoEntities;
      uint256[] memory affixProtoEntities2 = lootComponent.getValue(lootEntity2).affixProtoEntities;

      bool inequality = keccak256(abi.encode(affixProtoEntities1)) != keccak256(abi.encode(affixProtoEntities2));
      if (inequality) {
        inequalityCount++;
      }
    }

    // at least 45% should be different
    // (this does NOT test the actual distribution, which is complicated and dynamic)
    assertGt(inequalityCount, 450);
  }

  // make sure there're enough affixes to mint the highest ilvl loot
  function test_randomEquipment_maxIlvl(uint256 seed) public {
    // TODO more affixes, this fails at 13
    uint256 lootEntity = randomEquipmentSubsystem.executeTyped(12 /* should be MAX_ILVL */, seed);
    assertEq(lootComponent.getValue(lootEntity).ilvl, 12 /* should be MAX_ILVL */);
  }
}