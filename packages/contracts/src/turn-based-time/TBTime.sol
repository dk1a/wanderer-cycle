// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import { ScopedValue } from "@dk1a/solecslib/contracts/scoped-value/ScopedValue.sol";
import { FromPrototype } from "@dk1a/solecslib/contracts/prototype/FromPrototype.sol";
import { ScopedValueFromPrototype } from "@dk1a/solecslib/contracts/scoped-value/ScopedValueFromPrototype.sol";
import { ID as TBTimeScopeComponentID } from "./TBTimeScopeComponent.sol";
import { ID as TBTimeValueComponentID } from "./TBTimeValueComponent.sol";
import { ID as FromPrototypeComponentID } from "../common/FromPrototypeComponent.sol";

import { LibEffect } from "../effect/LibEffect.sol";

struct TimeStruct {
  bytes4 timeTopic;
  uint256 timeValue;
}

/**
 * @title Scoped turn-based time manager.
 * @dev Topic/scope allows parallel time-concepts, e.g. "round" and "turn"
 */
library TBTime {
  using ScopedValueFromPrototype for ScopedValueFromPrototype.Self;

  struct Self {
    IUint256Component components;
    ScopedValueFromPrototype.Self sv;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component components,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      components: components,
      sv: ScopedValueFromPrototype.__construct(
        ScopedValue.__construct(
          components,
          TBTimeScopeComponentID,
          TBTimeValueComponentID
        ),
        FromPrototype.__construct(
          components,
          FromPrototypeComponentID,
          // instance context
          abi.encode("TBTime", targetEntity)
        )
      ),
      targetEntity: targetEntity
    });
  }

  // TODO scope can maybe be improved
  function _scope(Self memory __self, bytes4 topic) private pure returns (bytes memory) {
    return abi.encode(__self.targetEntity, topic);
  }

  // ========== WRITE ==========

  function increase(
    Self memory __self,
    uint256 protoEntity,
    TimeStruct memory time
  ) internal returns (bool isUpdate) {
    return __self.sv.increaseEntity(
      _scope(__self, time.timeTopic),
      protoEntity,
      time.timeValue
    );
  }

  function remove(
    Self memory __self,
    uint256 protoEntity
  ) internal {
    __self.sv.removeEntity(protoEntity);
  }

  // TODO why call it scope internally and topic externally?
  function decreaseTopic(
    Self memory __self,
    TimeStruct memory time
  ) internal {
    uint256[] memory removedProtoEntities
      = __self.sv.decreaseScope(_scope(__self, time.timeTopic), time.timeValue);
    if (removedProtoEntities.length == 0) return;

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
  ) internal view returns (bool) {
    return __self.sv.has(protoEntity);
  }
}