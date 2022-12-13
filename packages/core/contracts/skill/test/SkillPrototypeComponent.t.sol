// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { Test } from "../../Test.sol";

import {
  SkillType,
  TargetType,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "../SkillPrototypeComponent.sol";
import {
  SkillPrototypeExtComponent,
  ID as SkillPrototypeExtComponentID
} from "../SkillPrototypeExtComponent.sol";
import {
  EffectPrototypeComponent,
  ID as EffectPrototypeComponentID
} from "../../effect/EffectPrototypeComponent.sol";

contract SkillPrototypeComponentTest is Test {
  SkillPrototypeComponent protoComp;
  SkillPrototypeExtComponent protoExtComp;
  EffectPrototypeComponent effectProtoComp;

  // sample skill entities
  uint256 chargePE = uint256(keccak256('Charge'));
  uint256 parryPE = uint256(keccak256('Parry'));
  uint256 cleavePE = uint256(keccak256('Cleave'));

  function setUp() public virtual override {
    super.setUp();

    protoComp = SkillPrototypeComponent(
      getAddressById(world.components(), SkillPrototypeComponentID)
    );
    protoExtComp = SkillPrototypeExtComponent(
      getAddressById(world.components(), SkillPrototypeExtComponentID)
    );
    effectProtoComp = EffectPrototypeComponent(
      getAddressById(world.components(), EffectPrototypeComponentID)
    );
  }

  function testSampleEffectStatmodsLength() public {
    assertEq(effectProtoComp.getValue(chargePE).statmods.length, 1);
  }

  function testSampleName() public {
    assertEq(protoExtComp.getValue(chargePE).name, 'Charge');
  }

  function testSampleTargetTypes() public {
    assertTrue(protoComp.getValue(chargePE).effectTarget == TargetType.SELF);
    assertTrue(protoComp.getValue(parryPE).effectTarget == TargetType.SELF);
    assertTrue(protoComp.getValue(cleavePE).effectTarget == TargetType.SELF);
  }

  function testSampelSkillTypes() public {
    assertTrue(protoComp.getValue(chargePE).skillType == SkillType.NONCOMBAT);
    assertTrue(protoComp.getValue(parryPE).skillType == SkillType.PASSIVE);
    assertTrue(protoComp.getValue(cleavePE).skillType == SkillType.COMBAT);
  }
}