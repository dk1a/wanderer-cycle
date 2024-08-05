// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { hasKey } from "@latticexyz/world-modules/src/modules/keysintable/hasKey.sol";

import { EffectTemplate, EffectTemplateData, EffectApplied, EffectAppliedData, EffectDuration } from "../../codegen/index.sol";
import { Statmod } from "../statmod/Statmod.sol";
import { Duration, GenericDurationData } from "../duration/Duration.sol";

library LibEffect {
  error LibEffect_InvalidApplicationEntity();

  function applyTimedEffect(
    bytes32 targetEntity,
    bytes32 applicationEntity,
    GenericDurationData memory duration
  ) internal {
    applyEffect(targetEntity, applicationEntity);

    Duration.increase(EffectDuration._tableId, targetEntity, applicationEntity, duration);
  }

  function applyEffect(bytes32 targetEntity, bytes32 applicationEntity) internal {
    if (!hasEffectTemplate(applicationEntity)) {
      revert LibEffect_InvalidApplicationEntity();
    }
    // Get and apply template effect data
    EffectTemplateData memory effect = EffectTemplate.get(applicationEntity);

    if (!hasEffectApplied(targetEntity, applicationEntity)) {
      // Set applied effect data
      // (this is to avoid statmod leaks on effect removal, in case template changes)
      EffectApplied.set(targetEntity, applicationEntity, effect.entities, effect.values);
      // Increase statmods
      // TODO figure out what to do if statmods are empty
      for (uint256 i; i < effect.entities.length; i++) {
        Statmod.increase(targetEntity, effect.entities[i], effect.values[i]);
      }
    }
    // TODO extend/refresh existing effect by applying it again
  }

  function remove(bytes32 targetEntity, bytes32 applicationEntity) internal {
    if (!hasEffectApplied(targetEntity, applicationEntity)) {
      // Nothing to remove
      return;
    }
    // Get and remove applied effect data
    // (template isn't used in removal, so its statmods can change without leaking)
    EffectAppliedData memory effect = EffectApplied.get(targetEntity, applicationEntity);
    EffectApplied.deleteRecord(targetEntity, applicationEntity);
    // Subtract statmods
    for (uint256 i; i < effect.entities.length; i++) {
      Statmod.decrease(targetEntity, effect.entities[i], effect.values[i]);
    }
  }

  /**
   * Returns true if `applicationEntity` has an effect template
   */
  function hasEffectTemplate(bytes32 applicationEntity) internal view returns (bool) {
    bytes32[] memory keyTuple = new bytes32[](1);
    keyTuple[0] = applicationEntity;
    return hasKey(EffectTemplate._tableId, keyTuple);
  }

  /**
   * Returns true if `targetEntity` has an ongoing effect for `applicationEntity`
   */
  function hasEffectApplied(bytes32 targetEntity, bytes32 applicationEntity) internal view returns (bool) {
    bytes32[] memory keyTuple = new bytes32[](2);
    keyTuple[0] = targetEntity;
    keyTuple[1] = applicationEntity;
    return hasKey(EffectApplied._tableId, keyTuple);
  }
}
