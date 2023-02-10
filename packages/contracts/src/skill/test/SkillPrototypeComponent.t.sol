// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";

import { SkillType, TargetType, getSkillProtoEntity } from "../SkillPrototypeComponent.sol";

contract SkillPrototypeComponentTest is BaseTest {
  // sample Skill entities
  uint256 chargePE = getSkillProtoEntity("Charge");
  uint256 parryPE = getSkillProtoEntity("Parry");
  uint256 cleavePE = getSkillProtoEntity("Cleave");

  function setUp() public virtual override {
    super.setUp();
  }

  // TODO this should be in effect tests (make those)
  function test_sample_effectPrototype_statmodLengths() public {
    assertEq(effectPrototypeComponent.getValue(chargePE).statmodProtoEntities.length, 1);
    assertEq(effectPrototypeComponent.getValue(chargePE).statmodValues.length, 1);
  }

  function test_sample_skillPrototype_name() public {
    assertEq(nameComponent.getValue(chargePE), "Charge");
  }

  function test_sample_skillPrototype_targetTypes() public {
    assertTrue(skillPrototypeComponent.getValue(chargePE).effectTarget == TargetType.SELF);
    assertTrue(skillPrototypeComponent.getValue(parryPE).effectTarget == TargetType.SELF);
    assertTrue(skillPrototypeComponent.getValue(cleavePE).effectTarget == TargetType.SELF);
  }

  function test_sample_skillPrototype_skillTypes() public {
    assertTrue(skillPrototypeComponent.getValue(chargePE).skillType == SkillType.NONCOMBAT);
    assertTrue(skillPrototypeComponent.getValue(parryPE).skillType == SkillType.PASSIVE);
    assertTrue(skillPrototypeComponent.getValue(cleavePE).skillType == SkillType.COMBAT);
  }
}
