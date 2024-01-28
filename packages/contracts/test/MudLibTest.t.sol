// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

abstract contract MudLibTest is MudTest {
  function setUp() public virtual override {
    super.setUp();

    address testContractAddress = address(this);
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);
    IWorld(worldAddress).grantAccess(WorldResourceIdLib.encodeNamespace(""), testContractAddress);
  }
}
