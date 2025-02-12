// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { BEFORE_SET_RECORD, AFTER_SPLICE_STATIC_DATA, BEFORE_DELETE_RECORD } from "@latticexyz/store/src/storeHookTypes.sol";

import { Module } from "@latticexyz/world/src/Module.sol";

import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { revertWithBytes } from "@latticexyz/world/src/revertWithBytes.sol";

import { StatmodHook } from "./StatmodHook.sol";
import { StatmodValue, StatmodIdxList, StatmodIdxMap } from "./codegen/index.sol";

contract StatmodModule is Module {
  // The StatmodHook is deployed once and infers the target table id
  // from the source table id (passed as argument to the hook methods)
  StatmodHook private immutable hook = new StatmodHook();

  function installRoot(bytes memory encodedArgs) public override {
    // Naive check to ensure this is only installed once
    // TODO: only revert if there's nothing to do
    requireNotInstalled(__self, encodedArgs);

    IBaseWorld world = IBaseWorld(_world());

    // Initialize variable to reuse in low level calls
    bool success;
    bytes memory returnData;

    // Grant the hook access to the tables
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (StatmodIdxList._tableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(world.grantAccess, (StatmodIdxMap._tableId, address(hook)))
    );
    if (!success) revertWithBytes(returnData);

    // Register a hook that is called when a value is set in the source table
    (success, returnData) = address(world).delegatecall(
      abi.encodeCall(
        world.registerStoreHook,
        (StatmodValue._tableId, hook, BEFORE_SET_RECORD | AFTER_SPLICE_STATIC_DATA | BEFORE_DELETE_RECORD)
      )
    );
  }

  function install(bytes memory) public pure override {
    revert Module_NonRootInstallNotSupported();
  }
}
