// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { SkillTemplate, EffectTemplate, Name } from "../src/codegen/index.sol";
import { SkillType, TargetType } from "../src/codegen/common.sol";
import { LibSkill } from "../src/skill/LibSkill.sol";

contract SkillTemplateTest is MudLibTest {
  // sample skill entities
  bytes32 cleavePE;
  bytes32 chargePE;
  bytes32 parryPE;

  function setUp() public virtual override {
    super.setUp();

    cleavePE = LibSkill.getSkillEntity("Cleave");
    chargePE = LibSkill.getSkillEntity("Charge");
    parryPE = LibSkill.getSkillEntity("Parry");
  }

  // TODO this should be in effect tests (make those)
  function test_sample_effectPrototype_statmodLengths() public {
    assertEq(EffectTemplate.get(chargePE).entities.length, 1);
    assertEq(EffectTemplate.get(chargePE).values.length, 1);
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
