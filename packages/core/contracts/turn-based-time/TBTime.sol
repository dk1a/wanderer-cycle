// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ScopedValue } from "../scoped-value/ScopedValue.sol";
import { ID as TBTimeScopeComponentID } from "./TBTimeScopeComponent.sol";
import { ID as TBTimeValueComponentID } from "./TBTimeValueComponent.sol";

import { LibEffect } from "../effect/LibEffect.sol";

struct TimeStruct {
  bytes4 timeTopic;
  uint256 timeValue;
}

/**
 * @title Scoped time values.
 * TODO much unfinished
 */
library TBTime {
  using ScopedValue for ScopedValue.Self;

  struct Self {
    IUint256Component components;
    ScopedValue.Self sv;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component components,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      components: components,
      sv: ScopedValue.__construct(
        components,
        TBTimeScopeComponentID,
        TBTimeValueComponentID
      ),
      targetEntity: targetEntity
    });
  }

  function _scope(Self memory __self, bytes4 topic) private pure returns (bytes memory) {
    return abi.encode(__self.targetEntity, topic);
  }

  /// TODO this is just copypasta from Statmod, generalize common parts

  function _appliedEntity(Self memory __self, uint256 protoEntity) private pure returns (uint256) {
    // TODO are u sure it's fine to make entities this way?
    unchecked {
      return protoEntity + __self.targetEntity + _appliedEntitySalt;
    }
  }

  uint256 internal constant _appliedEntitySalt = uint256(keccak256("_appliedEntitySalt"));

  function _protoEntity(Self memory __self, uint256 appliedEntity) private pure returns (uint256) {
    unchecked {
      return appliedEntity - __self.targetEntity - _appliedEntitySalt;
    }
  }

  // ========== WRITE ==========

  function increase(
    Self memory __self,
    uint256 protoEntity,
    TimeStruct memory time
  ) internal returns (bool isUpdate) {
    return __self.sv.increaseEntity(
      _scope(__self, time.timeTopic),
      _appliedEntity(__self, protoEntity),
      time.timeValue
    );
  }

  function remove(
    Self memory __self,
    uint256 protoEntity
  ) internal {
    __self.sv.removeEntity(
      _appliedEntity(__self, protoEntity)
    );
  }

  function decreaseTopic(
    Self memory __self,
    TimeStruct memory time
  ) internal {
    uint256[] memory removedAppliedEntities
      = __self.sv.decreaseScope(_scope(__self, time.timeTopic), time.timeValue);
    if (removedAppliedEntities.length == 0) return;

    // get protoEntities
    // (applied entities are only used internally to bind protoEntities to target)
    uint256[] memory removedProtoEntities = new uint256[](removedAppliedEntities.length);
    for (uint256 i; i < removedAppliedEntities.length; i++) {
      removedProtoEntities[i] = _protoEntity(__self, removedAppliedEntities[i]);
    }

    // effect callback
    // TODO make a proper callback system, rather than this hardcoded mess
    LibEffect.Self memory effect = LibEffect.__construct(__self.components, __self.targetEntity);
    for (uint256 i; i < removedProtoEntities.length; i++) {
      if (LibEffect._hasAppliedEntity(effect, removedProtoEntities[i])) {
        LibEffect._removeAppliedEntity(effect, removedProtoEntities[i]);
      }
    }
  }

  // ========== READ ==========

  function has(
    Self memory __self,
    uint256 protoEntity
  ) internal view returns(bool) {
    return __self.sv.has(
      _appliedEntity(__self, protoEntity)
    );
  }
}