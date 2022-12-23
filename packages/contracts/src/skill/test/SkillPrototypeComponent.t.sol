// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { Test } from "../../Test.sol";

import {
  SkillType,
  TargetType,
  getSkillProtoEntity,
  SkillPrototypeComponent,
  ID as SkillPrototypeComponentID
} from "../SkillPrototypeComponent.sol";
import {
  EffectPrototypeComponent,
  ID as EffectPrototypeComponentID
} from "../../effect/EffectPrototypeComponent.sol";
import { NameComponent, ID as NameComponentID } from "../../common/NameComponent.sol";

contract SkillPrototypeComponentTest is Test {
  SkillPrototypeComponent protoComp;
  EffectPrototypeComponent effectProtoComp;
  NameComponent nameComp;

  // sample skill entities
  uint256 chargePE = getSkillProtoEntity('Charge');
  uint256 parryPE = getSkillProtoEntity('Parry');
  uint256 cleavePE = getSkillProtoEntity('Cleave');

  function setUp() public virtual override {
    super.setUp();

    protoComp = SkillPrototypeComponent(
      getAddressById(world.components(), SkillPrototypeComponentID)
    );
    nameComp = NameComponent(
      getAddressById(world.components(), NameComponentID)
    );
    effectProtoComp = EffectPrototypeComponent(
      getAddressById(world.components(), EffectPrototypeComponentID)
    );
  }

  function testSampleEffectStatmodsLength() public {
    assertEq(effectProtoComp.getValue(chargePE).statmods.length, 1);
  }

  function testSampleName() public {
    assertEq(nameComp.getValue(chargePE), 'Charge');
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