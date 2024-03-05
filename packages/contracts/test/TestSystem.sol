// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { VmSafe } from "forge-std/Vm.sol";

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { WorldContextConsumer } from "@latticexyz/world/src/WorldContext.sol";
import { WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

// A simpler abstraction than System, TestSystem expects full root access instead of nuanced registration
// Mostly useful for wrapping internal calls for `expectRevert`
abstract contract TestSystem is WorldContextConsumer {
  constructor(address worldAddress) {
    StoreSwitch.setStoreAddress(worldAddress);
  }
}

function initTestSystem(address worldAddress, TestSystem testSystem) {
  VmSafe vm = VmSafe(address(uint160(uint256(keccak256("hevm cheat code")))));

  uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
  vm.broadcast(deployerPrivateKey);
  IWorld(worldAddress).grantAccess(WorldResourceIdLib.encodeNamespace(""), address(testSystem));
}
