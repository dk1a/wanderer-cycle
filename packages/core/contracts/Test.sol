// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { PRBTest } from "@prb/test/src/PRBTest.sol";

// this verbosity avoids ds-test (../lib/ds-test in forge-std can't work without submodules)
import { console } from "forge-std/console.sol";
import { console2 } from "forge-std/console2.sol";
import { stdError } from "forge-std/StdError.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { stdMath } from "forge-std/StdMath.sol";
import { StdStorage, stdStorage } from "forge-std/StdStorage.sol";
import { StdUtils } from "forge-std/StdUtils.sol";

import { LibDeploy } from "./libraries/LibDeploy.sol";
import { World } from "@latticexyz/solecs/src/World.sol";

abstract contract Test is PRBTest, StdUtils {
  World world;

  function setUp() public virtual {
    // deploy world
    world = new World();
    world.init();

    LibDeploy.deploy(address(this), address(world), false);
  }
}