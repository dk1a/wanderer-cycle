// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { MudTest } from "@latticexyz/world/test/MudTest.t.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { runPostDeployInitializers } from "../script/PostDeploy.s.sol";

abstract contract MudLibTest is MudTest {
  IWorld world;

  address alice = address(bytes20(keccak256("alice")));
  address bob = address(bytes20(keccak256("bob")));

  function setUp() public virtual override {
    super.setUp();

    // See the comment for runPostDeployInitializers
    // It is called here directly for optimization
    // This relies on `script` in `foundry.toml` skipping PostDeploy when deploying locally
    runPostDeployInitializers(vm, worldAddress);

    world = IWorld(worldAddress);

    address testContractAddress = address(this);
    _grantRootAccess(testContractAddress);
    _grantAccess("affix", testContractAddress);
    _grantAccess("duration", testContractAddress);
    _grantAccess("effect", testContractAddress);
    _grantAccess("statmod", testContractAddress);
    _grantAccess("wheel", testContractAddress);
  }

  function _grantRootAccess(address grantee) internal {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);
    world.grantAccess(WorldResourceIdLib.encodeNamespace(""), grantee);
  }

  function _grantAccess(bytes14 namespace, address grantee) internal {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.broadcast(deployerPrivateKey);
    world.grantAccess(WorldResourceIdLib.encodeNamespace(namespace), grantee);
  }
}
