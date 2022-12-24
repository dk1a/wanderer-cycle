// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { SkillType, TargetType, getSkillProtoEntity } from "../SkillPrototypeComponent.sol";

contract SkillPrototypeComponentTest is BaseTest {
  // sample skill entities
  uint256 chargePE = getSkillProtoEntity('Charge');
  uint256 parryPE = getSkillProtoEntity('Parry');
  uint256 cleavePE = getSkillProtoEntity('Cleave');

  function setUp() public virtual override {
    super.setUp();
  }

  function testSampleEffectStatmodsLength() public {
    assertEq(effectPrototypeComponent.getValue(chargePE).statmods.length, 1);
  }

  function testSampleName() public {
    assertEq(nameComponent.getValue(chargePE), 'Charge');
  }

  function testSampleTargetTypes() public {
    assertTrue(skillPrototypeComponent.getValue(chargePE).effectTarget == TargetType.SELF);
    assertTrue(skillPrototypeComponent.getValue(parryPE).effectTarget == TargetType.SELF);
    assertTrue(skillPrototypeComponent.getValue(cleavePE).effectTarget == TargetType.SELF);
  }

  function testSampelSkillTypes() public {
    assertTrue(skillPrototypeComponent.getValue(chargePE).skillType == SkillType.NONCOMBAT);
    assertTrue(skillPrototypeComponent.getValue(parryPE).skillType == SkillType.PASSIVE);
    assertTrue(skillPrototypeComponent.getValue(cleavePE).skillType == SkillType.COMBAT);
  }
}