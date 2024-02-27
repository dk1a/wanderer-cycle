// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { SkillTemplate, Name } from "../src/codegen/index.sol";
import { SkillType, TargetType } from "../src/codegen/common.sol";

contract SkillPrototypeComponentTest is MudLibTest {
  // sample skill entities
  bytes32 cleavePE = keccak256("Cleave");
  bytes32 chargePE = keccak256("Charge");
  bytes32 parryPE = keccak256("Parry");

  function setUp() public virtual override {
    super.setUp();
  }

  // TODO this should be in effect tests (make those)
  function test_sample_effectPrototype_statmodLengths() public {
    assertEq(effectPrototypeComponent.getValue(chargePE).statmodProtoEntities.length, 1);
    assertEq(effectPrototypeComponent.getValue(chargePE).statmodValues.length, 1);
  }

  function test_sample_skillPrototype_name() public {
    assertEq(Name.get(chargePE), "Charge");
  }

  function test_sample_skillPrototype_targetTypes() public {
    assertTrue(SkillTemplate.getTargetType(chargePE) == TargetType.SELF);
    assertTrue(SkillTemplate.getTargetType(parryPE) == TargetType.SELF);
    assertTrue(SkillTemplate.getTargetType(cleavePE) == TargetType.SELF);
  }

  function test_sample_skillPrototype_skillTypes() public {
    assertTrue(SkillTemplate.getSkillType(chargePE) == SkillType.NONCOMBAT);
    assertTrue(SkillTemplate.getSkillType(parryPE) == SkillType.PASSIVE);
    assertTrue(SkillTemplate.getSkillType(cleavePE) == SkillType.COMBAT);
  }
}
