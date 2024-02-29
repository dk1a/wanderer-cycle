// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BEFORE_SET_RECORD, AFTER_SPLICE_STATIC_DATA, AFTER_SPLICE_DYNAMIC_DATA, BEFORE_DELETE_RECORD } from "@latticexyz/store/src/storeHookTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";

import { Module } from "@latticexyz/world/src/Module.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { InstalledModules } from "@latticexyz/world/src/codegen/index.sol";

import { ResourceId, WorldResourceIdInstance } from "@latticexyz/world/src/WorldResourceId.sol";
import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { DurationHook } from "./DurationHook.sol";
import { GenericDuration, DurationIdxList, DurationIdxListTableId, DurationIdxMap, DurationIdxMapTableId } from "../../codegen/index.sol";

contract DurationModule is Module {
  using WorldResourceIdInstance for ResourceId;

  error DurationModule_InvalidKeySchema();
  error DurationModule_InvalidValueSchema();

  // The DurationHook is deployed once and infers the target table id
  // from the source table id (passed as argument to the hook methods)
  DurationHook private immutable hook = new DurationHook();

  function installRoot(bytes memory encodedArgs) public override {
    // Naive check to ensure this is only installed once
    // TODO: only revert if there's nothing to do
    requireNotInstalled(__self, encodedArgs);

    // Extract source table id from args
    ResourceId sourceTableId = ResourceId.wrap(abi.decode(encodedArgs, (bytes32)));

    IBaseWorld world = IBaseWorld(_world());

    // This is a custom module for a specific table, and it expects the appropriate schemas
    if (world.getKeySchema(sourceTableId).unwrap() != GenericDuration.getKeySchema().unwrap()) {
      revert DurationModule_InvalidKeySchema();
    }
    if (world.getValueSchema(sourceTableId).unwrap() != GenericDuration.getValueSchema().unwrap()) {
      revert DurationModule_InvalidValueSchema();
    }

    // Initialize variable to reuse in low level calls
    bool success;
    bytes memory returnData;

    // Register the tables
    if (!ResourceIds._getExists(DurationIdxListTableId)) {
      (success, returnData) = address(world).delegatecall(
        abi.encodeCall(
          world.registerTable,
          (
            DurationIdxListTableId,
            DurationIdxList.getFieldLayout(),
            DurationIdxList.getKeySchema(),
            DurationIdxList.getValueSchema(),
            DurationIdxList.getKeyNames(),
            DurationIdxList.getFieldNames()
          )
        )
      );
      if (!success) revertWithBytes(returnData);
    }
    if (!ResourceIds._getExists(DurationIdxMapTableId)) {
      (success, returnData) = address(world).delegatecall(
        abi.encodeCall(
          world.registerTable,
          (
            DurationIdxMapTableId,
            DurationIdxMap.getFieldLayout(),
            DurationIdxMap.getKeySchema(),
            DurationIdxMap.getValueSchema(),
            DurationIdxMap.getKeyNames(),
            DurationIdxMap.getFieldNames()
          )
        )
      );
      if (!success) revertWithBytes(returnData);
    }

    // Grant the hook access to the tables
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (DurationIdxListTableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (DurationIdxMapTableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    // Register a hook that is called when a value is set in the source table
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(
        world.registerStoreHook,
        (sourceTableId, hook, BEFORE_SET_RECORD | AFTER_SPLICE_STATIC_DATA | BEFORE_DELETE_RECORD)
      )
    );
  }

  function install(bytes memory) public pure {
    revert Module_NonRootInstallNotSupported();
  }
}
