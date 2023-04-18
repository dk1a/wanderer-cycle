// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { BaseTest } from "../../BaseTest.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import { console } from "forge-std/console.sol";

import { LibGuiseLevel } from "../LibGuiseLevel.sol";
import { LibExperience } from "../../charstat/LibExperience.sol";
import { PS_L } from "../../charstat/ExperienceComponent.sol";

import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "../ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "../GuisePrototypeComponent.sol";

contract LibGuiseLevelTest is BaseTest {
  using LibGuiseLevel for IUint256Component;
  using LibExperience for LibExperience.Self;

  ActiveGuiseComponent activeGuiseComp;
  GuisePrototypeComponent guiseProtoComp;

  uint256 targetEntity;

  function setup() public {
    world = address(this);
    activeGuiseComp = new ActiveGuiseComponent(world);
    guiseProtoComp = new GuisePrototypeComponent(world);
    targetEntity = 0;

    console.log(GuisePrototypeComponent);
    // Set up a GuisePrototype entity for the target entity
    uint256 guiseProtoEntity = guiseProtoComp.getGuiseProtoEntity("Warrior");
    GuisePrototype memory guisePrototype;
    guisePrototype.levelMul = [1, 2, 3];
    guiseProtoComp.set(guiseProtoEntity, guisePrototype);

    // Set up the ActiveGuiseComponent for the target entity
    activeGuiseComp.set(targetEntity, guiseProtoEntity);
  }

  function testGetAggregateLevel() public {
    // Create a new instance of LibExperience
    IUint256Component components = IUint256Component(world);
    LibExperience.Self memory exp = LibExperience.__construct(components, targetEntity);

    // Check that the aggregate level is correctly calculated
    uint32 expectedAggregateLevel = 6; // 1 + 2 + 3 = 6
    uint32 actualAggregateLevel = exp.getAggregateLevel(activeGuiseComp, guiseProtoComp, targetEntity);
    assertEq(expectedAggregateLevel, actualAggregateLevel);
  }

  function testMultiplyExperience() public {
    // Create an example array of experience to be multiplied
    uint32[PS_L] memory exp = [1, 2, 3];

    // Check that the experience is correctly multiplied by the guise level multipliers
    uint32[PS_L] memory expectedExpMultiplied = [1, 4, 9]; // [1*1, 2*2, 3*3] = [1, 4, 9]
    uint32[PS_L] memory actualExpMultiplied = LibGuiseLevel.multiplyExperience(
      IUint256Component(world),
      targetEntity,
      exp
    );
    assertEq(expectedExpMultiplied, actualExpMultiplied);
  }
}
