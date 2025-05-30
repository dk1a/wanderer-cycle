// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { BEFORE_DELETE_RECORD } from "@latticexyz/store/src/storeHookTypes.sol";

import { Module } from "@latticexyz/world/src/Module.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { effectInternalSystem } from "./codegen/systems/EffectInternalSystemLib.sol";
import { EffectDurationHook } from "./EffectDurationHook.sol";
import { EffectDuration } from "./codegen/index.sol";

contract EffectModule is Module {
  // The EffectDurationHook is deployed once and always uses the hardcoded EffectDuration._tableId
  EffectDurationHook private immutable hook = new EffectDurationHook();

  function installRoot(bytes memory) public override {
    requireNotInstalled(__self, "");

    IBaseWorld world = IBaseWorld(_world());

    // Initialize variable to reuse in low level calls
    bool success;
    bytes memory returnData;

    // Grant the hook access to the internal system
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (effectInternalSystem.toResourceId(), address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    // Register a hook that is called when a value is deleted from the source table
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.registerStoreHook, (EffectDuration._tableId, hook, BEFORE_DELETE_RECORD))
    );
  }

  function install(bytes memory) public pure override {
    revert Module_NonRootInstallNotSupported();
  }
}
