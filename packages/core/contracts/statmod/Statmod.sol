// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import {
  StatmodPrototype,
  Op, OP_L, OP_FINAL,
  Element, EL_L,
  StatmodPrototypeComponent,
  ID as StatmodPrototypeComponentID
} from "./StatmodPrototypeComponent.sol";

import { ScopedValue } from "../scoped-value/ScopedValue.sol";
import { ID as StatmodScopeComponentID } from "./StatmodScopeComponent.sol";
import { ID as StatmodValueComponentID } from "./StatmodValueComponent.sol";

/**
 * @title Scoped statmod values with aggregation depending on prototype.
 * @dev AVOID using ScopedValue directly for statmods.
 * Statmod has specific entity and scope composition.
 * And for reads it has specific aggregation logic.
 */
library Statmod {
  using ScopedValue for ScopedValue.Self;

  struct Self {
    StatmodPrototypeComponent protoComp;
    ScopedValue.Self sv;
    uint256 targetEntity;
  }

  function __construct(
    IUint256Component registry,
    uint256 targetEntity
  ) internal view returns (Self memory) {
    return Self({
      protoComp: StatmodPrototypeComponent(getAddressById(registry, StatmodPrototypeComponentID)),
      sv: ScopedValue.__construct(
        registry,
        StatmodScopeComponentID,
        StatmodValueComponentID
      ),
      targetEntity: targetEntity
    });
  }

  function _scope(Self memory __self, bytes4 topic) private pure returns (bytes memory) {
    return abi.encode(__self.targetEntity, topic);
  }

  /**
   * @dev modEntity represents application of statmod to target
   */
  function _modEntity(Self memory __self, uint256 protoEntity) private pure returns (uint256) {
    // TODO are u sure it's fine to make entities this way?
    unchecked {
      return protoEntity + __self.targetEntity + _modEntitySalt;
    }
  }

  uint256 internal constant _modEntitySalt = uint256(keccak256("_modEntitySalt"));

  /**
   * @dev protoEntity is global info about what a modEntity does
   * It can be retrieved back from modEntity using targetEntity
   */
  function _protoEntity(Self memory __self, uint256 modEntity) private pure returns (uint256) {
    unchecked {
      return modEntity - __self.targetEntity - _modEntitySalt;
    }
  }

  // ========== WRITE ==========

  /**
   * @dev Increase statmod value for modEntity (composed from target and prototype).
   */
  function increase(
    Self memory __self,
    uint256 protoEntity,
    uint256 value
  ) internal returns (bool isUpdate) {
    StatmodPrototype memory prototype
      = __self.protoComp.getValue(protoEntity);

    return __self.sv.increaseEntity(
      _scope(__self, prototype.topic),
      _modEntity(__self, protoEntity),
      value
    );
  }

  /**
   * @dev Decrease statmod value for modEntity (composed from target and prototype).
   */
  function decrease(
    Self memory __self,
    uint256 protoEntity,
    uint256 value
  ) internal returns (bool isUpdate) {
    StatmodPrototype memory prototype
      = __self.protoComp.getValue(protoEntity);

    return __self.sv.decreaseEntity(
      _scope(__self, prototype.topic),
      _modEntity(__self, protoEntity),
      value
    );
  }

  // ========== READ ==========

  /**
   * @dev Sum all statmod values for `topic`
   * TODO is this even useful anywhere?
   */
  function getTotal(
    Self memory __self,
    bytes4 topic
  ) internal view returns (uint32 result) {
    uint256[] memory modEntities = __self.sv.getEntities(_scope(__self, topic));
    uint256[] memory values = __self.sv.getValuesForEntities(modEntities);

    for (uint256 i; i < modEntities.length; i++) {
      result += uint32(values[i]);
    }
  }

  /**
   * @dev Sum statmod values for `topic`, grouped by Op.
   * This method shouldn't usually be needed externally, see getValues.
   */
  function getOperands(
    Self memory __self,
    bytes4 topic
  ) internal view returns(uint32[OP_L] memory result) {
    uint256[] memory modEntities = __self.sv.getEntities(_scope(__self, topic));
    uint256[] memory values = __self.sv.getValuesForEntities(modEntities);

    for (uint256 i; i < modEntities.length; i++) {
      uint256 modEntity = modEntities[i];
      uint256 value = values[i];

      StatmodPrototype memory prototype
        = __self.protoComp.getValue(_protoEntity(__self, modEntity));

      result[uint256(prototype.op)] += uint32(value);
    }
  }

  /**
   * @dev Sum statmod values for `topic`, grouped by Element and Op.
   * This method shouldn't usually be needed externally, see getValuesElemental.
   */
  function getOperandsElemental(
    Self memory __self,
    bytes4 topic
  ) internal view returns(uint32[EL_L][OP_L] memory result) {
    uint256[] memory modEntities = __self.sv.getEntities(_scope(__self, topic));
    uint256[] memory values = __self.sv.getValuesForEntities(modEntities);

    for (uint256 i; i < modEntities.length; i++) {
      uint256 modEntity = modEntities[i];
      uint256 value = values[i];

      StatmodPrototype memory prototype
        = __self.protoComp.getValue(_protoEntity(__self, modEntity));

      result[uint256(prototype.op)][uint256(prototype.element)] += uint32(value);
    }

    // Element.ALL applies to all other elements at the same time
    for (uint256 i = 1; i < EL_L; i++) {
      result[uint256(Op.ADD)][i] += result[uint256(Op.ADD)][uint256(Element.ALL)];
      result[uint256(Op.MUL)][i] += result[uint256(Op.MUL)][uint256(Element.ALL)];
      result[uint256(Op.BADD)][i] += result[uint256(Op.BADD)][uint256(Element.ALL)];
    }
  }

  /**
   * @dev Return statmod values grouped by results of operations.
   * Usually you want OP_FINAL - the last operation in their sequence.
   * The others give access to intermediate values like 'base life'
   * @param baseValue inherent base, may be 0
   * @return result results of operations upon `baseValue`
   */
  function getValues(
    Self memory __self,
    bytes4 topic,
    uint32 baseValue
  ) internal view returns (uint32[OP_L] memory result) {
    uint32[OP_L] memory ops = getOperands(__self, topic);
    result[uint256(Op.BADD)] = baseValue + ops[uint256(Op.BADD)];
    result[uint256(Op.MUL)] =
      result[uint256(Op.BADD)] * (100 + ops[uint256(Op.MUL)]) / 100;
    result[uint256(Op.ADD)] =
      result[uint256(Op.MUL)] + ops[uint256(Op.ADD)];
  }

  /**
   * @dev Result of all `topic` operations upon `baseValue`
   */
  function getValuesFinal(
    Self memory __self,
    bytes4 topic,
    uint32 baseValue
  ) internal view returns (uint32) {
    return getValues(__self, topic, baseValue)[OP_FINAL];
  }

  /**
   * @dev Return values grouped by Element and Op
   * See getValues for details on Op grouping
   */
  function getValuesElemental(
    Self memory __self,
    bytes4 topic,
    uint32[EL_L] memory baseValues
  ) internal view returns (uint32[EL_L][OP_L] memory result) {
    uint32[EL_L][OP_L] memory ops = getOperandsElemental(__self, topic);
    // el is Element enum values
    for (uint256 el; el < EL_L; el++) {
      uint32 baseValue = baseValues[el];

      // Element.ALL adds to all other elements at the same time
      if (el != uint256(Element.ALL)) {
        baseValue += baseValues[uint256(Element.ALL)];
      }

      result[uint256(Op.BADD)][el] = baseValue + ops[uint256(Op.BADD)][el];
      result[uint256(Op.MUL)][el] =
        result[uint256(Op.BADD)][el] * (100 + ops[uint256(Op.MUL)][el]) / 100;
      result[uint256(Op.ADD)][el] =
        result[uint256(Op.MUL)][el] + ops[uint256(Op.ADD)][el];
    }
  }

  /**
   * @dev Result of all `topic` operations upon `baseValue` grouped by Element
   */
  function getValuesElementalFinal(
    Self memory __self,
    bytes4 topic,
    uint32[EL_L] memory baseValues
  ) internal view returns (uint32[EL_L] memory) {
    return getValuesElemental(__self, topic, baseValues)[OP_FINAL];
  }
}