// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";
import {
  EffectRemovability,
  EffectStatmod,
  EffectPrototype,
  EffectPrototypeComponent,
  ID as EffectPrototypeComponentID
} from "./EffectPrototypeComponent.sol";
import { AppliedEffectComponent, ID as AppliedEffectComponentID } from "./AppliedEffectComponent.sol";
import { Statmod } from "../statmod/Statmod.sol";

library LibEffect {
  error LibEffect__InvalidProtoEntity();

  struct Self {
    EffectPrototypeComponent protoComp;
    AppliedEffectComponent appliedComp;
    Statmod.Self statmod;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component components,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      protoComp: EffectPrototypeComponent(getAddressById(components, EffectPrototypeComponentID)),
      appliedComp: AppliedEffectComponent(getAddressById(components, AppliedEffectComponentID)),
      statmod: Statmod.__construct(components, targetEntity),
      targetEntity: targetEntity
    });
  }

  function _appliedEntity(Self memory __self, uint256 protoEntity) internal pure returns (uint256) {
    return uint256(keccak256(
      abi.encode('AppliedEffect', __self.targetEntity, protoEntity)
    ));
  }

  function isEffectProto(Self memory __self, uint256 protoEntity) internal view returns (bool) {
    return __self.protoComp.has(protoEntity);
  }

  function has(Self memory __self, uint256 protoEntity) internal view returns (bool) {
    return _hasAppliedEntity(__self, _appliedEntity(__self, protoEntity));
  }

  // TODO this method shouldn't really exist, but TBTime doesn't know protoEntities
  function _hasAppliedEntity(Self memory __self, uint256 appliedEntity) internal view returns (bool) {
    return __self.appliedComp.has(appliedEntity);
  }

  function applyEffect(
    Self memory __self,
    uint256 protoEntity
  ) internal {
    // valid effect prototype required
    if (!__self.protoComp.has(protoEntity)) {
      revert LibEffect__InvalidProtoEntity();
    }
    EffectPrototype memory effect = __self.protoComp.getValue(protoEntity);
    // effect prototypes may be global, so applied entity is target-specific 
    uint256 appliedEntity = _appliedEntity(__self, protoEntity);

    bool effectExists = has(__self, protoEntity);
    if (!effectExists) {
      // set applied effect data
      // (this is to avoid statmod leaks on effect removal, in case prototype changes)
      __self.appliedComp.set(appliedEntity, effect);
      // increase statmods
      // TODO figure out what to do if statmods are empty
      for (uint256 i; i < effect.statmods.length; i++) {
        Statmod.increase(
          __self.statmod,
          effect.statmods[i].statmodProtoEntity,
          effect.statmods[i].value
        );
      }
    }
  }

  function remove(
    Self memory __self,
    uint256 protoEntity
  ) internal {
    _removeAppliedEntity(__self, _appliedEntity(__self, protoEntity));
  }

  // TODO this method shouldn't really exist, but TBTime doesn't know protoEntities
  function _removeAppliedEntity(
    Self memory __self,
    uint256 appliedEntity
  ) internal {
    // get and remove applied effect data
    // (prototype isn't used in removal, so its statmods can change without leaking)
    EffectPrototype memory effect = __self.appliedComp.getValue(appliedEntity);
    __self.appliedComp.remove(appliedEntity);
    // subtract statmods
    for (uint256 i; i < effect.statmods.length; i++) {
      Statmod.decrease(
        __self.statmod,
        effect.statmods[i].statmodProtoEntity,
        effect.statmods[i].value
      );
    }
  }
}