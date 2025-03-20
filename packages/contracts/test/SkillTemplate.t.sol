// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudLibTest } from "./MudLibTest.t.sol";
import { EffectTemplate } from "../src/namespaces/effect/LibEffect.sol";
import { SkillTemplate, SkillName } from "../src/namespaces/root/codegen/index.sol";
import { SkillType, TargetType } from "../src/codegen/common.sol";
import { LibSkill } from "../src/namespaces/root/skill/LibSkill.sol";

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
  function testSampleEffectTemplateStatmodLengths() public {
    assertEq(EffectTemplate.get(chargePE).entities.length, 1);
    assertEq(EffectTemplate.get(chargePE).values.length, 1);
  }

  function testSampleSkillTemplateName() public {
    assertEq(SkillName.get(chargePE), "Charge");
  }

  function testSampleSkillTemplateTargetTypes() public {
    assertTrue(SkillTemplate.getTargetType(chargePE) == TargetType.SELF);
    assertTrue(SkillTemplate.getTargetType(parryPE) == TargetType.SELF);
    assertTrue(SkillTemplate.getTargetType(cleavePE) == TargetType.SELF);
  }

  function testSampleSkillTemplateSkillTypes() public {
    assertTrue(SkillTemplate.getSkillType(chargePE) == SkillType.NONCOMBAT);
    assertTrue(SkillTemplate.getSkillType(parryPE) == SkillType.PASSIVE);
    assertTrue(SkillTemplate.getSkillType(cleavePE) == SkillType.COMBAT);
  }
}
