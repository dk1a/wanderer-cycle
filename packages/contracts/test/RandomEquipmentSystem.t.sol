// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { MudLibTest } from "./MudLibTest.t.sol";

import { AffixPartId } from "../src/codegen/common.sol";
import { LootAffixes, LootIlvl, EquipmentTypeComponent } from "../src/namespaces/root/codegen/index.sol";
import { EquipmentType } from "../src/namespaces/root/equipment/EquipmentType.sol";
import { Affix, AffixData } from "../src/namespaces/affix/codegen/index.sol";
import { EffectTemplate } from "../src/namespaces/effect/codegen/index.sol";
import { MAX_ILVL } from "../src/namespaces/affix/constants.sol";

contract RandomEquipmentSystemTest is MudLibTest {
  // tests basic assumptions, and that 2 mints don't break each other
  function testRandomEquipment2(uint256 seed1, uint256 seed2) public {
    vm.assume(seed1 != seed2);

    uint32 ilvl1 = 1;
    uint32 ilvl2 = 5;

    bytes32 lootEntity1 = world.mintRandomEquipmentEntity(ilvl1, seed1);
    bytes32 lootEntity2 = world.mintRandomEquipmentEntity(ilvl2, seed2);

    // check entities
    assertNotEq(lootEntity1, lootEntity2);
    assertNotEq(lootEntity1, 0);
    assertNotEq(lootEntity2, 0);
    // check loot-specific data
    bytes32[] memory lootAffixes1 = LootAffixes.get(lootEntity1);
    bytes32[] memory lootAffixes2 = LootAffixes.get(lootEntity2);
    assertEq(LootIlvl.get(lootEntity1), ilvl1);
    assertEq(LootIlvl.get(lootEntity2), ilvl2);
    assertEq(lootAffixes1.length, 1, "1: LootAffixes length");
    assertEq(lootAffixes2.length, 2, "2: LootAffixes length");
    // check affixesx
    assertGt(Affix.getValue(lootAffixes1[0]), 0);
    assertGt(Affix.getValue(lootAffixes2[0]), 0);
    assertGt(Affix.getValue(lootAffixes2[1]), 0);
    assertEq(uint8(Affix.getPartId(lootAffixes1[0])), uint8(AffixPartId.IMPLICIT));
    assertEq(uint8(Affix.getPartId(lootAffixes2[0])), uint8(AffixPartId.IMPLICIT));
    assertEq(uint8(Affix.getPartId(lootAffixes2[1])), uint8(AffixPartId.PREFIX));
    // check equipment type
    assertNotEq(EquipmentType.unwrap(EquipmentTypeComponent.get(lootEntity1)), bytes32(0));
    assertNotEq(EquipmentType.unwrap(EquipmentTypeComponent.get(lootEntity2)), bytes32(0));
    // check effect prototype
    bytes32[] memory effectStatmodEntities1 = EffectTemplate.getStatmodEntities(lootEntity1);
    bytes32[] memory effectStatmodEntities2 = EffectTemplate.getStatmodEntities(lootEntity2);
    uint32[] memory effectStatmodValues1 = EffectTemplate.getValues(lootEntity1);
    uint32[] memory effectStatmodValues2 = EffectTemplate.getValues(lootEntity2);
    assertEq(effectStatmodEntities1.length, 1, "1: effectStatmodEntities.length");
    assertEq(effectStatmodEntities2.length, 2, "2: effectStatmodEntities.length");
    assertEq(effectStatmodValues1[0], Affix.getValue(lootAffixes1[0]), "1[0]: statmod values != affix values");
    assertEq(effectStatmodValues2[0], Affix.getValue(lootAffixes2[0]), "2[0]: statmod values != affix values");
    assertEq(effectStatmodValues2[1], Affix.getValue(lootAffixes2[1]), "2[1]: statmod values != affix values");
  }

  // affixes and equipment proto should be identical, but otherwise these should be 2 different entities
  function testRandomEquipmentSameSeed(uint256 seed) public {
    bytes32 lootEntity1 = world.mintRandomEquipmentEntity(1, seed);
    bytes32 lootEntity2 = world.mintRandomEquipmentEntity(1, seed);
    assertNotEq(lootEntity1, lootEntity2);
    assertEq(
      EquipmentType.unwrap(EquipmentTypeComponent.get(lootEntity1)),
      EquipmentType.unwrap(EquipmentTypeComponent.get(lootEntity2))
    );
    bytes32[] memory lootAffixes1 = LootAffixes.get(lootEntity1);
    bytes32[] memory lootAffixes2 = LootAffixes.get(lootEntity2);
    assertEq(lootAffixes1.length, 1);
    assertEq(lootAffixes1.length, lootAffixes2.length);

    AffixData memory affix1 = Affix.get(lootAffixes1[0]);
    AffixData memory affix2 = Affix.get(lootAffixes2[0]);
    assertEq(affix1.affixPrototypeEntity, affix2.affixPrototypeEntity);
    assertEq(uint8(affix1.partId), uint8(affix2.partId));
    assertEq(affix1.value, affix2.value);
    assertEq(
      abi.encode(EffectTemplate.get(lootEntity1)),
      abi.encode(EffectTemplate.get(lootEntity2)),
      "effect templates not equal"
    );
  }

  // ensure that mint can actually produce different affixes
  function testRandomEquipmentDifferentAffixes() public {
    uint256 inequalityCount;
    for (uint256 i; i < 1000; i++) {
      uint256 seed1 = 1000000 + i;
      uint256 seed2 = 2000000 + i;

      bytes32 lootEntity1 = world.mintRandomEquipmentEntity(1, seed1);
      bytes32 lootEntity2 = world.mintRandomEquipmentEntity(1, seed2);
      assertNotEq(lootEntity1, lootEntity2);
      bytes32[] memory lootAffixes1 = LootAffixes.get(lootEntity1);
      bytes32[] memory lootAffixes2 = LootAffixes.get(lootEntity2);

      bool inequality = keccak256(abi.encode(lootAffixes1)) != keccak256(abi.encode(lootAffixes2));
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
    // TODO more affixes
    bytes32 lootEntity = world.mintRandomEquipmentEntity(MAX_ILVL, seed);
    assertEq(LootIlvl.get(lootEntity), MAX_ILVL);
  }
}
