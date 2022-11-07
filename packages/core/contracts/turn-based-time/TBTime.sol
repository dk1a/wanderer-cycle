// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import {
  TBTimePrototype,
  TBTimePrototypeComponent,
  ID as TBTimePrototypeComponentID
} from "./TBTimePrototypeComponent.sol";

import { ScopedValue } from "../scoped-value/ScopedValue.sol";
import { ID as TBTimeScopeComponentID } from "./TBTimeScopeComponent.sol";
import { ID as TBTimeValueComponentID } from "./TBTimeValueComponent.sol";

/**
 * @title Scoped time values.
 * TODO much unfinished
 */
library TBTime {
  using ScopedValue for ScopedValue.Self;

  struct Self {
    TBTimePrototypeComponent protoComp;
    ScopedValue.Self sv;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component registry,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      protoComp: TBTimePrototypeComponent(getAddressById(registry, TBTimePrototypeComponentID)),
      sv: ScopedValue.__construct(
        registry,
        TBTimeScopeComponentID,
        TBTimeValueComponentID
      ),
      targetEntity: targetEntity
    });
  }

  function _getTopic(Self memory __self, uint256 protoEntity) private view returns (bytes4) {
    return __self.protoComp.getValue(protoEntity).topic;
  }

  function _scope(Self memory __self, bytes4 topic) private pure returns (bytes memory) {
    return abi.encode(__self.targetEntity, topic);
  }

  /// TODO this is just copypasta from Statmod, generalize common parts

  function _appliedEntity(Self memory __self, uint256 protoEntity) private pure returns (uint256) {
    // TODO are u sure it's fine to make entities this way?
    unchecked {
      return protoEntity + __self.targetEntity;
    }
  }

  function _protoEntity(Self memory __self, uint256 appliedEntity) private pure returns (uint256) {
    unchecked {
      return appliedEntity - __self.targetEntity;
    }
  }

  // ========== WRITE ==========

  function increase(
    Self memory __self,
    uint256 protoEntity,
    uint256 value
  ) internal returns (bool isUpdate) {
    bytes4 topic = _getTopic(__self, protoEntity);
    return __self.sv.increaseEntity(
      _scope(__self, topic),
      _appliedEntity(__self, protoEntity),
      value
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
    bytes4 topic,
    uint256 value
  ) internal {
    uint256[] memory removedAppliedEntities
      = __self.sv.decreaseScope(_scope(__self, topic), value);

    for (uint256 i; i < removedAppliedEntities.length; i++) {
      uint256 appliedEntity = removedAppliedEntities[i];
      uint256 protoEntity = _protoEntity(__self, appliedEntity);

      TBTimePrototype memory prototype = __self.protoComp.getValue(protoEntity);
      if (prototype.onEndRemoveEffect) {
        // TODO like, remove the effect
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