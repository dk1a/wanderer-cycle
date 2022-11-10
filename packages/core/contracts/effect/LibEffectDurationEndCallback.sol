// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import {
  AppliedEffect,
  AppliedEffectComponent,
  ID as AppliedEffectComponentID
} from "./AppliedEffectComponent.sol";
import { Statmod } from "../statmod/Statmod.sol";

library LibEffectDurationEndCallback {
  function callback(
    IUint256Component registry,
    uint256 targetEntity,
    uint256[] memory effectEntities
  ) internal {
    AppliedEffectComponent appliedEffectComp
      = AppliedEffectComponent(getAddressById(registry, AppliedEffectComponentID));
    Statmod.Self memory statmod = Statmod.__construct(registry, targetEntity);
    
    for (uint256 i; i < effectEntities.length; i++) {
      bool withRemove = appliedEffectComp.has(effectEntities[i]);
      if (withRemove) {
        _remove(appliedEffectComp, statmod, effectEntities[i]);
      }
    }
  }

  // TODO I don't like how it duplicates most of LibEffect.remove
  function _remove(
    AppliedEffectComponent appliedEffectComp,
    Statmod.Self memory statmod,
    uint256 appliedEntity
  ) private {
    // get and remove effect data
    AppliedEffect memory data = appliedEffectComp.getValue(appliedEntity);
    appliedEffectComp.remove(appliedEntity);
    // subtract statmods
    for (uint256 i; i < data.statmods.length; i++) {
      Statmod.decrease(
        statmod,
        data.statmods[i].statmodProtoEntity,
        data.statmods[i].value
      );
    }
  }
}