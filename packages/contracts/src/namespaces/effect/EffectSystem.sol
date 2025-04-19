// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { GenericDurationData } from "../duration/Duration.sol";
import { LibEffect } from "./LibEffect.sol";

contract EffectSystem is System {
  function applyTimedEffect(
    bytes32 targetEntity,
    bytes32 applicationEntity,
    GenericDurationData memory duration
  ) public {
    LibEffect.applyTimedEffect(targetEntity, applicationEntity, duration);
  }

  function applyEffect(bytes32 targetEntity, bytes32 applicationEntity) public {
    LibEffect.applyEffect(targetEntity, applicationEntity);
  }

  function remove(bytes32 targetEntity, bytes32 applicationEntity) public {
    LibEffect.remove(targetEntity, applicationEntity);
  }
}
