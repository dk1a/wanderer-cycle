// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BaseTest } from "./BaseTest.t.sol";
import { affixSystem } from "../src/namespaces/affix/codegen/systems/AffixSystemLib.sol";
import { _pickAffixValue } from "../src/namespaces/affix/AffixSystem.sol";
import { LibAddAffixPrototype } from "../src/namespaces/affix/LibAddAffixPrototype.sol";
import { AffixPrototype, AffixPrototypeData } from "../src/namespaces/affix/codegen/tables/AffixPrototype.sol";
import { AffixPrototypeAvailable } from "../src/namespaces/affix/codegen/tables/AffixPrototypeAvailable.sol";
import { Affix } from "../src/namespaces/affix/codegen/tables/Affix.sol";
import { AffixPart, AffixAvailabilityTargetId } from "../src/namespaces/affix/types.sol";
import { AffixPartId } from "../src/codegen/common.sol";

contract AffixSystemTest is BaseTest {
  AffixAvailabilityTargetId internal targetId =
    AffixAvailabilityTargetId.wrap(keccak256("test affixAvailabilityTargetId"));

  bytes32 fakeStatmodEntity = hex"f5be";
  bytes32 affixPrototypeEntity1;
  bytes32 affixPrototypeEntity2;
  bytes32 affixPrototypeEntity3;

  function setUp() public virtual override {
    super.setUp();

    AffixPart[] memory affixParts = new AffixPart[](2);
    affixParts[0] = AffixPart({
      partId: AffixPartId.PREFIX,
      affixAvailabilityTargetId: targetId,
      label: "test prefix"
    });
    affixParts[1] = AffixPart({
      partId: AffixPartId.SUFFIX,
      affixAvailabilityTargetId: targetId,
      label: "test suffix"
    });

    affixPrototypeEntity1 = LibAddAffixPrototype.addAffixPrototype(
      AffixPrototypeData({
        statmodEntity: fakeStatmodEntity,
        exclusiveGroup: "eg1",
        affixTier: 1,
        requiredLevel: 1,
        min: 1,
        max: 10,
        name: "affixPrototype1"
      }),
      affixParts,
      1
    );

    affixPrototypeEntity2 = LibAddAffixPrototype.addAffixPrototype(
      AffixPrototypeData({
        statmodEntity: fakeStatmodEntity,
        exclusiveGroup: "eg2",
        affixTier: 1,
        requiredLevel: 1,
        min: 1,
        max: 10,
        name: "affixPrototype2"
      }),
      affixParts,
      1
    );

    affixPrototypeEntity3 = LibAddAffixPrototype.addAffixPrototype(
      AffixPrototypeData({
        statmodEntity: fakeStatmodEntity,
        exclusiveGroup: "eg2",
        affixTier: 1,
        requiredLevel: 1,
        min: 1,
        max: 10,
        name: "affixPrototype3"
      }),
      affixParts,
      1
    );
  }

  function testSetUp() public view {
    bytes32[] memory availableEntities = new bytes32[](3);
    availableEntities[0] = affixPrototypeEntity1;
    availableEntities[1] = affixPrototypeEntity2;
    availableEntities[2] = affixPrototypeEntity3;
    uint32 ilvl = 1;
    assertEq(AffixPrototypeAvailable.get(AffixPartId.PREFIX, targetId, ilvl), availableEntities);
    assertEq(AffixPrototypeAvailable.get(AffixPartId.SUFFIX, targetId, ilvl), availableEntities);
  }

  function testPickAffixes() public {
    AffixPartId[] memory affixPartIds = new AffixPartId[](2);
    affixPartIds[0] = AffixPartId.PREFIX;
    affixPartIds[1] = AffixPartId.SUFFIX;

    bytes32[] memory excludeAffixes = new bytes32[](0);

    // If exlusion doesn't work properly, 123 seed should lead to 2 entity2 picks
    bytes32[] memory affixEntities = affixSystem.instantiateRandomAffixes(
      affixPartIds,
      excludeAffixes,
      targetId,
      1,
      123
    );
    assertEq(affixEntities.length, 2);

    (
      bytes32[] memory affixProtoEntities,
      bytes32[] memory statmodEntities,
      uint32[] memory affixValues
    ) = _extractAffixesData(affixEntities);

    assertEq(affixProtoEntities[0], affixPrototypeEntity2);
    assertEq(affixProtoEntities[1], affixPrototypeEntity1);

    assertEq(statmodEntities[0], fakeStatmodEntity);
    assertEq(statmodEntities[1], fakeStatmodEntity);

    assertEq(affixValues[0], 5);
    assertEq(affixValues[1], 2);
  }

  function testPickAffixValue() public pure {
    assertEq(_pickAffixValue(0, 0, 0), 0);
    assertEq(_pickAffixValue(0, 0, 100), 0);
    assertEq(_pickAffixValue(10, 100, 0), 51);
    assertEq(_pickAffixValue(10, 100, 123), 25);
    assertEq(_pickAffixValue(89, 90, 122), 89);
    assertEq(_pickAffixValue(89, 90, 448), 90);
  }

  function testManuallyPickAffixesMax() public {
    AffixPartId[] memory affixPartIds = new AffixPartId[](2);
    affixPartIds[0] = AffixPartId.PREFIX;
    affixPartIds[1] = AffixPartId.SUFFIX;

    string[] memory names = new string[](2);
    names[0] = "affixPrototype1";
    names[1] = "affixPrototype2";

    uint32[] memory tiers = new uint32[](2);
    tiers[0] = 1;
    tiers[1] = 1;

    bytes32[] memory affixEntities = affixSystem.instantiateManualAffixesMax(affixPartIds, names, tiers);
    assertEq(affixEntities.length, 2);

    (
      bytes32[] memory affixProtoEntities,
      bytes32[] memory statmodEntities,
      uint32[] memory affixValues
    ) = _extractAffixesData(affixEntities);

    assertEq(affixProtoEntities[0], affixPrototypeEntity1);
    assertEq(affixProtoEntities[1], affixPrototypeEntity2);

    assertEq(statmodEntities[0], fakeStatmodEntity);
    assertEq(statmodEntities[1], fakeStatmodEntity);

    assertEq(affixValues[0], 10);
    assertEq(affixValues[1], 10);
  }

  function _extractAffixesData(
    bytes32[] memory affixEntities
  )
    internal
    view
    returns (bytes32[] memory affixProtoEntities, bytes32[] memory statmodEntities, uint32[] memory affixValues)
  {
    affixProtoEntities = new bytes32[](affixEntities.length);
    statmodEntities = new bytes32[](affixEntities.length);
    affixValues = new uint32[](affixEntities.length);

    for (uint256 i; i < affixEntities.length; i++) {
      affixProtoEntities[i] = Affix.getAffixPrototypeEntity(affixEntities[i]);
      statmodEntities[i] = AffixPrototype.getStatmodEntity(affixProtoEntities[i]);
      affixValues[i] = Affix.getValue(affixEntities[i]);
    }
  }
}
