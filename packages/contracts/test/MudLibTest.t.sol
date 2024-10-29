// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

abstract contract MudLibTest is MudTest {
  IWorld world;

  address alice = address(bytes20(keccak256("alice")));
  address bob = address(bytes20(keccak256("bob")));

  function setUp() public virtual override {
    super.setUp();

    world = IWorld(worldAddress);

    address testContractAddress = address(this);
    _grantRootAccess(testContractAddress);
  }

  function _grantRootAccess(address grantee) internal {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);
    world.grantAccess(WorldResourceIdLib.encodeNamespace(""), grantee);
  }
}
