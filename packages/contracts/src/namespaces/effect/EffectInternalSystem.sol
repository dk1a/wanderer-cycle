// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { GenericDurationData } from "../duration/Duration.sol";
import { LibEffect } from "./LibEffect.sol";

contract EffectInternalSystem is System {
  function internalRemoveEffect(bytes32 targetEntity, bytes32 applicationEntity) public {
    LibEffect.remove(targetEntity, applicationEntity);
  }
}
