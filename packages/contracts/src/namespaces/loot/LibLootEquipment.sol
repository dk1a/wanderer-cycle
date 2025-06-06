// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AffixPartId } from "../../codegen/common.sol";
import { EquipmentTypes as t, EquipmentType } from "../equipment/EquipmentType.sol";
import { EquipmentAffixAvailabilityTargetIds as a } from "../equipment/EquipmentAffixAvailabilityTargetIds.sol";
import { AffixAvailabilityTargetId } from "../affix/types.sol";
import { MAX_AFFIX_TIER } from "../affix/constants.sol";

library LibLootEquipment {
  error LibLootEquipment_InvalidAffixTier(uint256 affixTier);
  error LibLootEquipment_InvalidWeights(W[] weights);

  /// @dev Hardcoded affixTier => AffixPartsIds mapping
  function getAffixPartIds(uint256 affixTier) internal pure returns (AffixPartId[] memory result) {
    if (affixTier == 0) {
      revert LibLootEquipment_InvalidAffixTier(affixTier);
    } else if (affixTier == 1) {
      result = new AffixPartId[](1);
      result[0] = AffixPartId.IMPLICIT;
    } else if (affixTier == 2) {
      result = new AffixPartId[](2);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
    } else if (affixTier <= MAX_AFFIX_TIER) {
      result = new AffixPartId[](3);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
    } else {
      revert LibLootEquipment_InvalidAffixTier(affixTier);
    }
  }

  struct W {
    AffixAvailabilityTargetId targetId;
    EquipmentType equipmentType;
    uint256 weight;
  }

  /// @dev Randomly pick an equipment type.
  /// (Hardcoded affixTier => AffixAvailabilityTargetId,EquipmentType)
  function pickEquipmentTargetAndType(
    uint256 affixTier,
    uint256 randomness
  ) internal pure returns (AffixAvailabilityTargetId, EquipmentType) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickEquipmentTemplate"), randomness)));

    W[] memory w;

    if (affixTier == 0) {
      revert LibLootEquipment_InvalidAffixTier(affixTier);
    } else if (affixTier == 1) {
      w = new W[](5);
      w[0] = W(a.WEAPON, t.WEAPON, 32);
      w[1] = W(a.SHIELD, t.SHIELD, 16);
      w[2] = W(a.CLOTHING, t.CLOTHING, 32);
      w[3] = W(a.PANTS, t.PANTS, 16);
      w[4] = W(a.BOOTS, t.BOOTS, 16);
    } else if (affixTier == 2) {
      w = new W[](7);
      w[0] = W(a.WEAPON, t.WEAPON, 32);
      w[1] = W(a.SHIELD, t.SHIELD, 32);
      w[2] = W(a.CLOTHING, t.CLOTHING, 32);
      w[3] = W(a.GLOVES, t.GLOVES, 16);
      w[4] = W(a.PANTS, t.PANTS, 32);
      w[5] = W(a.BOOTS, t.BOOTS, 32);
      w[6] = W(a.RING, t.RING, 4);
    } else if (affixTier <= MAX_AFFIX_TIER) {
      w = new W[](9);
      w[0] = W(a.WEAPON, t.WEAPON, 32);
      w[1] = W(a.SHIELD, t.SHIELD, 32);
      w[2] = W(a.HAT, t.HAT, 16);
      w[3] = W(a.CLOTHING, t.CLOTHING, 32);
      w[4] = W(a.GLOVES, t.GLOVES, 32);
      w[5] = W(a.PANTS, t.PANTS, 32);
      w[6] = W(a.BOOTS, t.BOOTS, 32);
      w[7] = W(a.AMULET, t.AMULET, 4);
      w[8] = W(a.RING, t.RING, 8);
    } else {
      revert LibLootEquipment_InvalidAffixTier(affixTier);
    }

    uint256 index = _sampleIndex(randomness, w);
    return (w[index].targetId, w[index].equipmentType);
  }

  /// @dev Weighted sample.
  function _sampleIndex(uint256 randomness, W[] memory weights) private pure returns (uint256) {
    uint256 totalWeight;
    for (uint256 i; i < weights.length; i++) {
      totalWeight += weights[i].weight;
    }
    uint256 roll = randomness % totalWeight;
    for (uint256 i; i < weights.length; i++) {
      totalWeight -= weights[i].weight;
      if (roll >= totalWeight) {
        return i;
      }
    }
    revert LibLootEquipment_InvalidWeights(weights);
  }
}
