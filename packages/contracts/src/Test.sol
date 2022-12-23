// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { PRBTest } from "@prb/test/src/PRBTest.sol";

import { LibDeploy } from "./libraries/LibDeploy.sol";
import { World } from "@latticexyz/solecs/src/World.sol";

abstract contract Test is PRBTest {
  World world;

  function setUp() public virtual {
    // deploy world
    world = new World();
    world.init();

    LibDeploy.deploy(address(this), address(world), false);
  }
}