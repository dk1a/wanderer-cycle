// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";
import { StatmodPrototype, Op, OP_L, OP_FINAL, Element, EL_L, StatmodPrototypeComponent, ID as StatmodPrototypeComponentID } from "./StatmodPrototypeComponent.sol";

import { ScopedValue } from "@dk1a/solecslib/contracts/scoped-value/ScopedValue.sol";
import { FromPrototype } from "@dk1a/solecslib/contracts/prototype/FromPrototype.sol";
import { ScopedValueFromPrototype } from "@dk1a/solecslib/contracts/scoped-value/ScopedValueFromPrototype.sol";

/*StatmodBase: {
  ...entityKey,
  schema: "bytes32",
},
FromStatmodBase: entityRelation,
StatmodBaseOpts: {
  ...entityKey,
  schema: {
    statmodOp: "StatmodOp",
    eleStat: "EleStat",
  }
},
StatmodScope: {
  primaryKeys: {
    targetEntity: EntityId,
    baseEntity: EntityId,
  },
  schema: "bytes32"
},
StatmodValue: {
  primaryKeys: {
    targetEntity: EntityId,
    baseEntity: EntityId,
  },
  schema: "uint32"
},*/

import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { StatmodBase, FromStatmodBase, StatmodBaseOpts, StatmodScope, StatmodValue } from "../codegen/Tables.sol";

/**
 * @title Scoped statmod values with aggregation depending on prototype.
 */
library Statmod {
  error Statmod_IncreaseByZero();
  error Statmod_DecreaseByZero();
  error Statmod_EntityAbsent();

  /**
   * @dev Increase statmod value for targeted baseEntity.
   */
  function increase(uint256 targetEntity, uint256 baseEntity, uint256 value) internal returns (bool isUpdate) {
    if (value == 0) revert Statmod_IncreaseByZero();

    uint32 storedValue = StatmodValue.get(targetEntity, baseEntity);

    bytes32 statmodBase = StatmodBase.get(baseEntity);

    isUpdate = storedValue != 0;
    if (statmodBase != StatmodScope.get(targetEntity, baseEntity)) {
      StatmodScope.set(targetEntity, baseEntity, statmodBase);
    }
    StatmodValue.set(targetEntity, baseEntity, storedValue + value);

    return isUpdate;
  }

  /**
   * @dev Decrease statmod value for targeted baseEntity.
   */
  function decrease(uint256 targetEntity, uint256 baseEntity, uint256 value) internal returns (bool isUpdate) {
    if (value == 0) revert ScopedValue__DecreaseByZero();

    uint32 storedValue = StatmodValue.get(targetEntity, baseEntity);
    if (storedValue == 0) revert ScopedValue__EntityAbsent();

    bytes32 statmodBase = StatmodBase.get(baseEntity);

    isUpdate = storedValue > value;
    if (statmodBase != StatmodScope.get(targetEntity, baseEntity)) {
      StatmodScope.set(targetEntity, baseEntity, statmodBase);
    }
    if (isUpdate) {
      StatmodValue.set(targetEntity, baseEntity, storedValue - value);
    } else {
      StatmodValue.deleteRecord(targetEntity, baseEntity);
    }

    return isUpdate;
  }

  // ========== READ ==========

  /**
   * @dev Sum statmod values for `baseEntity`, grouped by Op.
   * This method shouldn't usually be needed externally, see getValues.
   */
  function getOperands(uint256 targetEntity, uint256 baseEntity) internal view returns (uint32[OP_L] memory result) {
    (uint256[] memory protoEntities, uint256[] memory values) = getKeysWithValue();

    for (uint256 i; i < protoEntities.length; i++) {
      StatmodPrototype memory prototype = __self.protoComp.getValue(protoEntities[i]);

      result[uint256(prototype.op)] += uint32(values[i]);
    }
  }

  /**
   * @dev Sum statmod values for `topicEntity`, grouped by Element and Op.
   * This method shouldn't usually be needed externally, see getValuesElemental.
   */
  function getOperandsElemental(
    Self memory __self,
    uint256 topicEntity
  ) internal view returns (uint32[EL_L][OP_L] memory result) {
    (uint256[] memory protoEntities, uint256[] memory values) = __self.sv.getEntitiesValues(
      _scope(__self, topicEntity)
    );

    for (uint256 i; i < protoEntities.length; i++) {
      StatmodPrototype memory prototype = __self.protoComp.getValue(protoEntities[i]);

      result[uint256(prototype.op)][uint256(prototype.element)] += uint32(values[i]);
    }

    // Element.ALL applies to all other elements at the same time
    for (uint256 el; el < EL_L; el++) {
      if (el == uint256(Element.ALL)) continue;

      result[uint256(Op.ADD)][el] += result[uint256(Op.ADD)][uint256(Element.ALL)];
      result[uint256(Op.MUL)][el] += result[uint256(Op.MUL)][uint256(Element.ALL)];
      result[uint256(Op.BADD)][el] += result[uint256(Op.BADD)][uint256(Element.ALL)];
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
    uint256 topicEntity,
    uint32 baseValue
  ) internal view returns (uint32[OP_L] memory result) {
    uint32[OP_L] memory ops = getOperands(__self, topicEntity);
    result[uint256(Op.BADD)] = baseValue + ops[uint256(Op.BADD)];
    result[uint256(Op.MUL)] = (result[uint256(Op.BADD)] * (100 + ops[uint256(Op.MUL)])) / 100;
    result[uint256(Op.ADD)] = result[uint256(Op.MUL)] + ops[uint256(Op.ADD)];
  }

  /**
   * @dev Result of all `topicEntity` operations upon `baseValue`
   */
  function getValuesFinal(Self memory __self, uint256 topicEntity, uint32 baseValue) internal view returns (uint32) {
    return getValues(__self, topicEntity, baseValue)[OP_FINAL];
  }

  /**
   * @dev Return values grouped by Element and Op
   * See getValues for details on Op grouping
   */
  function getValuesElemental(
    Self memory __self,
    uint256 topicEntity,
    uint32[EL_L] memory baseValues
  ) internal view returns (uint32[EL_L][OP_L] memory result) {
    uint32[EL_L][OP_L] memory ops = getOperandsElemental(__self, topicEntity);
    // el is Element enum values
    for (uint256 el; el < EL_L; el++) {
      uint32 baseValue = baseValues[el];

      // Element.ALL adds to all other elements at the same time
      if (el != uint256(Element.ALL)) {
        baseValue += baseValues[uint256(Element.ALL)];
      }

      result[uint256(Op.BADD)][el] = baseValue + ops[uint256(Op.BADD)][el];
      result[uint256(Op.MUL)][el] = (result[uint256(Op.BADD)][el] * (100 + ops[uint256(Op.MUL)][el])) / 100;
      result[uint256(Op.ADD)][el] = result[uint256(Op.MUL)][el] + ops[uint256(Op.ADD)][el];
    }
  }

  /**
   * @dev Result of all `topicEntity` operations upon `baseValue` grouped by Element
   */
  function getValuesElementalFinal(
    Self memory __self,
    uint256 topicEntity,
    uint32[EL_L] memory baseValues
  ) internal view returns (uint32[EL_L] memory) {
    return getValuesElemental(__self, topicEntity, baseValues)[OP_FINAL];
  }
}
