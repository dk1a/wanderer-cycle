// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BEFORE_DELETE_RECORD } from "@latticexyz/store/src/storeHookTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";

import { Module } from "@latticexyz/world/src/Module.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { EffectDurationHook } from "./EffectDurationHook.sol";
import { EffectDuration, EffectTemplate, EffectApplied, StatmodValue } from "../../codegen/index.sol";

contract EffectModule is Module {
  // The EffectDurationHook is deployed once and always uses the hardcoded EffectDuration._tableId
  EffectDurationHook private immutable hook = new EffectDurationHook();

  function installRoot(bytes memory) public override {
    requireNotInstalled(__self, "");

    IBaseWorld world = IBaseWorld(_world());

    // Initialize variable to reuse in low level calls
    bool success;
    bytes memory returnData;

    // Register the tables
    if (!ResourceIds._getExists(EffectDuration._tableId)) {
      (success, returnData) = address(world).delegatecall(
        abi.encodeCall(
          world.registerTable,
          (
            EffectDuration._tableId,
            EffectDuration._fieldLayout,
            EffectDuration._keySchema,
            EffectDuration._valueSchema,
            EffectDuration.getKeyNames(),
            EffectDuration.getFieldNames()
          )
        )
      );
      if (!success) revertWithBytes(returnData);
    }
    if (!ResourceIds._getExists(EffectTemplate._tableId)) {
      (success, returnData) = address(world).delegatecall(
        abi.encodeCall(
          world.registerTable,
          (
            EffectTemplate._tableId,
            EffectTemplate._fieldLayout,
            EffectTemplate._keySchema,
            EffectTemplate._valueSchema,
            EffectTemplate.getKeyNames(),
            EffectTemplate.getFieldNames()
          )
        )
      );
      if (!success) revertWithBytes(returnData);
    }
    if (!ResourceIds._getExists(EffectApplied._tableId)) {
      (success, returnData) = address(world).delegatecall(
        abi.encodeCall(
          world.registerTable,
          (
            EffectApplied._tableId,
            EffectApplied._fieldLayout,
            EffectApplied._keySchema,
            EffectApplied._valueSchema,
            EffectApplied.getKeyNames(),
            EffectApplied.getFieldNames()
          )
        )
      );
      if (!success) revertWithBytes(returnData);
    }

    // Grant the hook access to the tables
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (EffectDuration._tableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (EffectTemplate._tableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (EffectApplied._tableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    // Grant the hook access to external tables
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (StatmodValue._tableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    // Register a hook that is called when a value is deleted from the source table
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.registerStoreHook, (EffectDuration._tableId, hook, BEFORE_DELETE_RECORD))
    );
  }

  function install(bytes memory) public pure {
    revert Module_NonRootInstallNotSupported();
  }
}
