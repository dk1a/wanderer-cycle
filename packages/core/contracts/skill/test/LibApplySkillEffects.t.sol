// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { Test } from "../../Test.sol";

import { World } from "solecs/World.sol";

import { SkillPrototypeComponent } from "../SkillPrototypeComponent.sol";
import { TBTimeScopeComponent } from "../../turn-based-time/TBTimeScopeComponent.sol";

import { LibApplySkillEffect } from "../LibApplySkillEffect.sol";

contract LibApplySkillEffectTest is Test {
  using LibApplySkillEffect for LibApplySkillEffect.Self;

  LibApplySkillEffect.Self _libASE;

  uint256 userEntity = uint256(keccak256('mainEntity'));

  function setUp() public virtual override {
    super.setUp();

    // init library's object
    _libASE = LibApplySkillEffect.__construct(
      world.components(),
      userEntity
    );

    // TODO something
  }
}