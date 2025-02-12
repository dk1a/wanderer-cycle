// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { LibPickAffix } from "../src/namespaces/root/affix/LibPickAffix.sol";
import { AffixPartId } from "../src/codegen/common.sol";
import { AffixPrototype, AffixPrototypeData } from "../src/namespaces/root/codegen/index.sol";

contract LibPickAffixTest is MudLibTest {
  bytes32 internal targetEntity = keccak256("targetEntity");

  /*function testPickAffixes() public {
    AffixPartId[] memory affixPartIds = new AffixPartId[](2);
    affixPartIds[0] = AffixPartId.PREFIX;
    affixPartIds[1] = AffixPartId.SUFFIX;

    // uint32[] memory excludeAffixes = new uint32[](0);

    bytes32[] memory availableEntities = new bytes32[](3);
    availableEntities[0] = keccak256("affix1");
    availableEntities[1] = keccak256("affix2");
    availableEntities[2] = keccak256("affix3");

    (
      bytes32[] memory statmodProtoEntities,
      bytes32[] memory affixProtoEntities,
      uint32[] memory affixValues
    ) = LibPickAffix.pickAffixes(affixPartIds, targetEntity, 1, 123);

    assertEq(statmodProtoEntities.length, 2);
    assertEq(affixProtoEntities.length, 2);
    assertEq(affixValues.length, 2);
  }

  function testManuallyPickAffixesMax() public {
    string[] memory names = new string[](2);
    names[0] = "affix1";
    names[1] = "affix2";

    uint32[] memory tiers = new uint32[](2);
    tiers[0] = 1;
    tiers[1] = 2;

    (
      bytes32[] memory statmodProtoEntities,
      bytes32[] memory affixProtoEntities,
      uint32[] memory affixValues
    ) = LibPickAffix.manuallyPickAffixesMax(names, tiers);

    assertEq(statmodProtoEntities.length, 2);
    assertEq(affixProtoEntities.length, 2);
    assertEq(affixValues.length, 2);
  }*/

  // To test this function, we will need to make it accessible by making it public/external
  // or by adding a public/external function that calls it
  // function testPickAffixValue() public {
  //   // Initializing fake data for the test
  //   AffixPrototypeData memory affixProto = LibPickAffix.AffixPrototypeData({
  //     statmodProtoEntity: bytes32(0x123),
  //     tier: 1,
  //     requiredIlvl: 1,
  //     min: 1,
  //     max: 10
  //   });

  //   // call pickAffixValue
  //   uint32 affixValue = LibPickAffix._pickAffixValue(affixProto, 123);

  //   // Checking the results of the pickAffixValue
  //   assertEq(affixValue, 6);
  // }
}
