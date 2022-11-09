// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import {
  EffectRemovability,
  EffectStatmod,
  AppliedEffect,
  AppliedEffectComponent,
  ID as AppliedEffectComponentID
} from "./AppliedEffectComponent.sol";
import { TBTime, TimeStruct } from "../turn-based-time/TBTime.sol";
import { Statmod } from "../statmod/Statmod.sol";

library LibEffect {
  struct Self {
    AppliedEffectComponent comp;
    TBTime.Self tbtime;
    Statmod.Self statmod;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component registry,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      comp: AppliedEffectComponent(getAddressById(registry, AppliedEffectComponentID)),
      tbtime: TBTime.__construct(registry, targetEntity),
      statmod: Statmod.__construct(registry, targetEntity),
      targetEntity: targetEntity
    });
  }

  function _appliedEntity(Self memory __self, uint256 protoEntity) private pure returns (uint256) {
    return uint256(keccak256(
      abi.encode('AppliedEffect', __self.targetEntity, protoEntity)
    ));
  }

  function exists(Self memory __self, uint256 protoEntity) internal view returns (bool) {
    return __self.comp.has(_appliedEntity(__self, protoEntity));
  }

  function applyEffect(
    Self memory __self,
    // TODO figure out what to do if statmods are empty
    AppliedEffect memory data,
    TimeStruct memory time
  ) internal {
    uint256 appliedEntity = _appliedEntity(__self, data.effectProtoEntity);

    // TODO infinite/absent duration
    // start/extend duration
    TBTime.increase(__self.tbtime, appliedEntity, time);

    bool effectExists = exists(__self, data.effectProtoEntity);
    if (!effectExists) {
      // set effect data
      __self.comp.set(appliedEntity, data);
      // increase statmods
      for (uint256 i; i < data.statmods.length; i++) {
        Statmod.increase(
          __self.statmod,
          data.statmods[i].statmodProtoEntity,
          data.statmods[i].value
        );
      }
    }
  }

  function remove(
    Self memory __self,
    uint256 protoEntity
  ) internal {
    uint256 appliedEntity = _appliedEntity(__self, protoEntity);
    // remove duration
    TBTime.remove(__self.tbtime, appliedEntity);
    // get and remove effect data
    AppliedEffect memory data = __self.comp.getValue(appliedEntity);
    __self.comp.remove(appliedEntity);
    // subtract statmods
    for (uint256 i; i < data.statmods.length; i++) {
      Statmod.decrease(
        __self.statmod,
        data.statmods[i].statmodProtoEntity,
        data.statmods[i].value
      );
    }
  }
}