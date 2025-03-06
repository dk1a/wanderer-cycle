// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BEFORE_SET_RECORD, AFTER_SPLICE_STATIC_DATA, AFTER_SPLICE_DYNAMIC_DATA, BEFORE_DELETE_RECORD } from "@latticexyz/store/src/storeHookTypes.sol";
import { ResourceIds } from "@latticexyz/store/src/codegen/tables/ResourceIds.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { Schema } from "@latticexyz/store/src/Schema.sol";

import { Module } from "@latticexyz/world/src/Module.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { InstalledModules } from "@latticexyz/world/src/codegen/index.sol";

import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { GenericDuration } from "./codegen/tables/GenericDuration.sol";
import { Idx_GenericDuration_TargetEntityTimeId } from "./codegen/idxs/Idx_GenericDuration_TargetEntityTimeId.sol";

contract DurationModule is Module {
  error DurationModule_InvalidKeySchema();
  error DurationModule_InvalidValueSchema();

  function installRoot(bytes memory encodedArgs) public override {
    // Naive check to ensure this is only installed once
    // TODO: only revert if there's nothing to do
    requireNotInstalled(__self, encodedArgs);

    // Extract source table id from args
    ResourceId sourceTableId = ResourceId.wrap(abi.decode(encodedArgs, (bytes32)));

    IBaseWorld world = IBaseWorld(_world());

    // This is a custom module for a specific table, and it expects the appropriate schemas
    if (world.getKeySchema(sourceTableId).unwrap() != GenericDuration._keySchema.unwrap()) {
      revert DurationModule_InvalidKeySchema();
    }
    if (world.getValueSchema(sourceTableId).unwrap() != GenericDuration._valueSchema.unwrap()) {
      revert DurationModule_InvalidValueSchema();
    }

    // Register the idx
    Idx_GenericDuration_TargetEntityTimeId.register(sourceTableId);
  }

  function install(bytes memory) public pure override {
    revert Module_NonRootInstallNotSupported();
  }
}
