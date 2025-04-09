// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BaseTest } from "./BaseTest.t.sol";
import { AffixAvailabilityTargetId, LibPickAffix, AffixPrototype, AffixPrototypeData } from "../src/namespaces/affix/LibPickAffix.sol";
import { AffixPrototypeAvailable } from "../src/namespaces/affix/codegen/tables/AffixPrototypeAvailable.sol";
import { AffixPartId } from "../src/codegen/common.sol";

contract LibPickAffixTest is BaseTest {
  AffixAvailabilityTargetId internal targetId = AffixAvailabilityTargetId.wrap(keccak256("affixAvailabilityTargetId"));

  bytes32 fakeStatmodEntity = hex"f5be";
  bytes32 affixPrototypeEntity1 = hex"aff1";
  bytes32 affixPrototypeEntity2 = hex"aff2";
  bytes32 affixPrototypeEntity3 = hex"aff3";

  function setUp() public virtual override {
    super.setUp();

    AffixPrototype.set(
      affixPrototypeEntity1,
      AffixPrototypeData({
        statmodEntity: fakeStatmodEntity,
        exclusiveGroup: "eg1",
        affixTier: 1,
        requiredLevel: 1,
        min: 1,
        max: 10,
        name: "affixPrototype1"
      })
    );

    AffixPrototype.set(
      affixPrototypeEntity2,
      AffixPrototypeData({
        statmodEntity: fakeStatmodEntity,
        exclusiveGroup: "eg2",
        affixTier: 1,
        requiredLevel: 1,
        min: 1,
        max: 10,
        name: "affixPrototype2"
      })
    );

    AffixPrototype.set(
      affixPrototypeEntity3,
      AffixPrototypeData({
        statmodEntity: fakeStatmodEntity,
        exclusiveGroup: "eg2",
        affixTier: 1,
        requiredLevel: 1,
        min: 1,
        max: 10,
        name: "affixPrototype3"
      })
    );
  }

  function testPickAffixes() public {
    AffixPartId[] memory affixPartIds = new AffixPartId[](2);
    affixPartIds[0] = AffixPartId.PREFIX;
    affixPartIds[1] = AffixPartId.SUFFIX;

    bytes32[] memory excludeAffixes = new bytes32[](0);

    uint32 ilvl = 1;

    bytes32[] memory availableEntities = new bytes32[](3);
    availableEntities[0] = affixPrototypeEntity1;
    availableEntities[1] = affixPrototypeEntity2;
    availableEntities[2] = affixPrototypeEntity3;
    AffixPrototypeAvailable.set(AffixPartId.PREFIX, targetId, ilvl, availableEntities);
    AffixPrototypeAvailable.set(AffixPartId.SUFFIX, targetId, ilvl, availableEntities);

    // If exlusion doesn't work properly, 123 seed should lead to 2 entity2 picks
    (bytes32[] memory statmodEntities, bytes32[] memory affixProtoEntities, uint32[] memory affixValues) = LibPickAffix
      .pickAffixes(affixPartIds, excludeAffixes, targetId, 1, 123);

    assertEq(statmodEntities.length, 2);
    assertEq(statmodEntities[0], fakeStatmodEntity);
    assertEq(statmodEntities[1], fakeStatmodEntity);

    assertEq(affixProtoEntities.length, 2);
    assertEq(affixProtoEntities[0], affixPrototypeEntity2);
    assertEq(affixProtoEntities[1], affixPrototypeEntity1);

    assertEq(affixValues.length, 2);
    assertEq(affixValues[0], 5);
    assertEq(affixValues[1], 2);
  }

  function testPickAffixValue() public {
    assertEq(LibPickAffix._pickAffixValue(0, 0, 0), 0);
    assertEq(LibPickAffix._pickAffixValue(0, 0, 100), 0);
    assertEq(LibPickAffix._pickAffixValue(10, 100, 0), 51);
    assertEq(LibPickAffix._pickAffixValue(10, 100, 123), 25);
    assertEq(LibPickAffix._pickAffixValue(89, 90, 122), 89);
    assertEq(LibPickAffix._pickAffixValue(89, 90, 448), 90);
  }

  function testManuallyPickAffixesMax() public {
    string[] memory names = new string[](2);
    names[0] = "affixPrototype1";
    names[1] = "affixPrototype2";

    uint32[] memory tiers = new uint32[](2);
    tiers[0] = 1;
    tiers[1] = 1;

    (bytes32[] memory statmodEntities, bytes32[] memory affixProtoEntities, uint32[] memory affixValues) = LibPickAffix
      .manuallyPickAffixesMax(names, tiers);

    assertEq(statmodEntities.length, 2);
    assertEq(statmodEntities[0], fakeStatmodEntity);
    assertEq(statmodEntities[1], fakeStatmodEntity);

    assertEq(affixProtoEntities.length, 2);
    assertEq(affixProtoEntities[0], affixPrototypeEntity1);
    assertEq(affixProtoEntities[1], affixPrototypeEntity2);

    assertEq(affixValues.length, 2);
    assertEq(affixValues[0], 10);
    assertEq(affixValues[1], 10);
  }
}
