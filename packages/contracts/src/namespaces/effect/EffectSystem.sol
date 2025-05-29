// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { SmartObjectFramework } from "../evefrontier/SmartObjectFramework.sol";

import { GenericDurationData } from "../duration/Duration.sol";
import { LibEffect } from "./LibEffect.sol";

// TODO are you sure applicationEntity doesn't need any requirements?
contract EffectSystem is SmartObjectFramework {
  function applyTimedEffect(
    bytes32 targetEntity,
    bytes32 applicationEntity,
    GenericDurationData memory duration
  ) public context {
    _requireEntityLeaf(uint256(targetEntity));
    LibEffect.applyTimedEffect(targetEntity, applicationEntity, duration);
  }

  function applyEffect(bytes32 targetEntity, bytes32 applicationEntity) public context {
    _requireEntityLeaf(uint256(targetEntity));
    LibEffect.applyEffect(targetEntity, applicationEntity);
  }

  function removeEffect(bytes32 targetEntity, bytes32 applicationEntity) public context {
    _requireEntityLeaf(uint256(targetEntity));
    LibEffect.remove(targetEntity, applicationEntity);
  }
}
