// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { StatmodBase, StatmodBaseData, StatmodValue, StatmodIdxList } from "../../codegen/index.sol";
import { StatmodOp, EleStat } from "../../codegen/common.sol";
import { StatmodOpFinal, StatmodOp_length, EleStat_length } from "../../CustomTypes.sol";
import { StatmodTopic } from "./StatmodTopic.sol";

library Statmod {
  error Statmod_IncreaseByZero();
  error Statmod_DecreaseByZero();
  error Statmod_EntityAbsent();

  /**
   * @dev Increase statmod value for targeted baseEntity
   */
  function increase(bytes32 targetEntity, bytes32 baseEntity, uint32 value) internal returns (bool isUpdate) {
    if (value == 0) revert Statmod_IncreaseByZero();

    uint32 storedValue = StatmodValue.get(targetEntity, baseEntity);
    isUpdate = storedValue != 0;

    StatmodValue.set(targetEntity, baseEntity, storedValue + value);

    return isUpdate;
  }

  /**
   * @dev Decrease statmod value for targeted baseEntity
   */
  function decrease(bytes32 targetEntity, bytes32 baseEntity, uint32 value) internal returns (bool isUpdate) {
    if (value == 0) revert Statmod_DecreaseByZero();

    uint32 storedValue = StatmodValue.get(targetEntity, baseEntity);
    if (storedValue == 0) revert Statmod_EntityAbsent();

    isUpdate = storedValue > value;
    if (isUpdate) {
      StatmodValue.set(targetEntity, baseEntity, storedValue - value);
    } else {
      StatmodValue.deleteRecord(targetEntity, baseEntity);
    }

    return isUpdate;
  }

  // ========== READ ==========

  /**
   * @dev Sum statmod values for statmodTopic, grouped by statmodOp.
   * This method shouldn't usually be needed externally, see getValues.
   */
  function getOperands(
    bytes32 targetEntity,
    StatmodTopic statmodTopic
  ) internal view returns (uint32[StatmodOp_length] memory result) {
    bytes32[] memory baseEntities = StatmodIdxList.get(targetEntity, statmodTopic);

    for (uint256 i; i < baseEntities.length; i++) {
      bytes32 baseEntity = baseEntities[i];
      StatmodOp statmodOp = StatmodBase.getStatmodOp(baseEntity);

      result[uint256(statmodOp)] += uint32(StatmodValue.get(targetEntity, baseEntity));
    }
  }

  /**
   * @dev Sum statmod values for statmodTopic, grouped by eleStat and statmodOp.
   * This method shouldn't usually be needed externally, see getValuesElemental.
   */
  function getOperandsElemental(
    bytes32 targetEntity,
    StatmodTopic statmodTopic
  ) internal view returns (uint32[EleStat_length][StatmodOp_length] memory result) {
    bytes32[] memory baseEntities = StatmodIdxList.get(targetEntity, statmodTopic);

    for (uint256 i; i < baseEntities.length; i++) {
      bytes32 baseEntity = baseEntities[i];
      StatmodBaseData memory data = StatmodBase.get(baseEntity);

      result[uint256(data.statmodOp)][uint256(data.eleStat)] += uint32(StatmodValue.get(targetEntity, baseEntity));
    }
  }

  /**
   * @dev Return statmod values grouped by results of operations.
   * Usually you want StatmodOpFinal - the last operation in their sequence.
   * The others give access to intermediate values like 'base life'
   * @param baseValue inherent base, may be 0
   * @return result results of operations upon `baseValue`
   */
  function getValues(
    bytes32 targetEntity,
    StatmodTopic statmodTopic,
    uint32 baseValue
  ) internal view returns (uint32[StatmodOp_length] memory result) {
    uint32[StatmodOp_length] memory ops = getOperands(targetEntity, statmodTopic);

    result[uint256(StatmodOp.BADD)] = baseValue + ops[uint256(StatmodOp.BADD)];

    result[uint256(StatmodOp.MUL)] = (result[uint256(StatmodOp.BADD)] * (100 + ops[uint256(StatmodOp.MUL)])) / 100;

    result[uint256(StatmodOp.ADD)] = result[uint256(StatmodOp.MUL)] + ops[uint256(StatmodOp.ADD)];
  }

  /**
   * @dev Result of all `statmodTopic` operations upon `baseValue`
   */
  function getValuesFinal(
    bytes32 targetEntity,
    StatmodTopic statmodTopic,
    uint32 baseValue
  ) internal view returns (uint32) {
    return getValues(targetEntity, statmodTopic, baseValue)[uint256(StatmodOpFinal)];
  }

  /**
   * @dev Return values grouped by EleStat and StatmodOp
   * See getValues for details on StatmodOp grouping
   */
  function getValuesElemental(
    bytes32 targetEntity,
    StatmodTopic statmodTopic,
    uint32[EleStat_length] memory baseValues
  ) internal view returns (uint32[EleStat_length][StatmodOp_length] memory result) {
    uint32[EleStat_length][StatmodOp_length] memory ops = getOperandsElemental(targetEntity, statmodTopic);
    // el is EleStat enum values
    for (uint256 el; el < EleStat_length; el++) {
      uint32 baseValue = baseValues[el];

      result[uint256(StatmodOp.BADD)][el] = baseValue + ops[uint256(StatmodOp.BADD)][el];
      result[uint256(StatmodOp.MUL)][el] =
        (result[uint256(StatmodOp.BADD)][el] * (100 + ops[uint256(StatmodOp.MUL)][el])) /
        100;
      result[uint256(StatmodOp.ADD)][el] = result[uint256(StatmodOp.MUL)][el] + ops[uint256(StatmodOp.ADD)][el];
    }
  }

  /**
   * @dev Result of all `statmodTopic` operations upon `baseValue` grouped by EleStat
   */
  function getValuesElementalFinal(
    bytes32 targetEntity,
    StatmodTopic statmodTopic,
    uint32[EleStat_length] memory baseValues
  ) internal view returns (uint32[EleStat_length] memory) {
    return getValuesElemental(targetEntity, statmodTopic, baseValues)[uint256(StatmodOpFinal)];
  }
}
