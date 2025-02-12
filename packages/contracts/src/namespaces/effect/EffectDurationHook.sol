// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { FieldLayout } from "@latticexyz/store/src/FieldLayout.sol";
import { StoreHook } from "@latticexyz/store/src/StoreHook.sol";
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { LibEffect } from "./LibEffect.sol";

contract EffectDurationHook is StoreHook {
  function _decodeKeyTuple(
    bytes32[] memory keyTuple
  ) private pure returns (bytes32 targetEntity, bytes32 applicationEntity) {
    targetEntity = keyTuple[0];
    applicationEntity = keyTuple[1];
  }

  function onBeforeDeleteRecord(ResourceId, bytes32[] memory keyTuple, FieldLayout) public override {
    (bytes32 targetEntity, bytes32 applicationEntity) = _decodeKeyTuple(keyTuple);

    LibEffect.remove(targetEntity, applicationEntity);
  }
}
