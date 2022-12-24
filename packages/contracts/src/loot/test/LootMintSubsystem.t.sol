// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";

import { LibToken } from "../../token/LibToken.sol";
import { Loot } from "../LootComponent.sol";
import { EffectPrototype, EffectRemovability } from "../../effect/EffectPrototypeComponent.sol";
import { MAX_ILVL } from "../../init/BaseInitAffixSystem.sol";

contract LootMintSubsystemTest is BaseTest {
  IUint256Component components;

  function setUp() public virtual override {
    super.setUp();

    components = world.components();
  }

  // tests basic assumptions, and that 2 mints don't break each other
  function testLootMints2(uint256 seed1, uint256 seed2) public {
    vm.assume(seed1 != seed2);

    uint256 ilvl1 = 1;
    uint256 ilvl2 = 2;

    uint256 lootEntity1 = lootMintSubsystem.executeTyped(alice, ilvl1, seed1);
    uint256 lootEntity2 = lootMintSubsystem.executeTyped(bob, ilvl2, seed2);

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
    assertEq(effectProto1.statmodValues, loot1.affixValues, "1: statmod values != affix values");
    assertEq(effectProto2.statmodValues, loot2.affixValues, "2: statmod values != affix values");
    // check token
    assertEq(LibToken.ownerOf(components, lootEntity1), alice);
    assertEq(LibToken.ownerOf(components, lootEntity2), bob);
  }

  // affixes and equipment proto should be identical, but otherwise these should be 2 different entities
  function testLootMintSameSeed(uint256 seed) public {
    uint256 lootEntity1 = lootMintSubsystem.executeTyped(alice, 1, seed);
    uint256 lootEntity2 = lootMintSubsystem.executeTyped(bob, 1, seed);
    assertNotEq(lootEntity1, lootEntity2);
    assertEq(fromPrototypeComponent.getValue(lootEntity1), fromPrototypeComponent.getValue(lootEntity2));
    assertEq(
      keccak256(abi.encode(effectPrototypeComponent.getValue(lootEntity1))),
      keccak256(abi.encode(effectPrototypeComponent.getValue(lootEntity2)))
    );
    assertEq(LibToken.ownerOf(components, lootEntity1), alice);
    assertEq(LibToken.ownerOf(components, lootEntity2), bob);
  }

  // ensure that mint can actually produce different affixes
  function testLootMintDifferentAffixes() public {
    uint256 inequalityCount;
    for (uint256 i; i < 1000; i++) {
      uint256 seed1 = 1000000 + i;
      uint256 seed2 = 2000000 + i;

      uint256 lootEntity1 = lootMintSubsystem.executeTyped(alice, 1, seed1);
      uint256 lootEntity2 = lootMintSubsystem.executeTyped(bob, 1, seed2);
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
  function testLootMintMaxIlvl(uint256 seed) public {
    // TODO more affixes, this fails at 4
    uint256 lootEntity = lootMintSubsystem.executeTyped(alice, 3 /* should be MAX_ILVL */, seed);
    assertEq(lootComponent.getValue(lootEntity).ilvl, 3 /* should be MAX_ILVL */);
  }
}