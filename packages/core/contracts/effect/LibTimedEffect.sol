// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";

import { TBTime, TimeStruct } from "../turn-based-time/TBTime.sol";
import { LibEffect } from "./LibEffect.sol";

library LibTimedEffect {
  using LibEffect for LibEffect.Self;

  struct Self {
    TBTime.Self tbtime;
    LibEffect.Self effect;
  }

  function __construct(
    IUint256Component components,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      tbtime: TBTime.__construct(components, targetEntity),
      effect: LibEffect.__construct(components, targetEntity)
    });
  }

  function isEffectProto(Self memory __self, uint256 protoEntity) internal view returns (bool) {
    return __self.effect.isEffectProto(protoEntity);
  }

  function has(Self memory __self, uint256 protoEntity) internal view returns (bool) {
    return __self.effect.has(protoEntity);
  }

  function applyEffect(
    Self memory __self,
    uint256 protoEntity,
    TimeStruct memory durationTime
  ) internal {
    __self.effect.applyEffect(protoEntity);

    // start/extend duration
    // (0 timeValue means infinite duration until removed)
    if (durationTime.timeValue > 0) {
      uint256 appliedEntity = __self.effect._appliedEntity(protoEntity);
      TBTime.increase(__self.tbtime, appliedEntity, durationTime);
    }
  }

  function remove(
    Self memory __self,
    uint256 protoEntity
  ) internal {
    __self.effect.remove(protoEntity);

    // remove duration
    uint256 appliedEntity = __self.effect._appliedEntity(protoEntity);
    TBTime.remove(__self.tbtime, appliedEntity);
  }
}