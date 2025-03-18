// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixPartId } from "../../../codegen/common.sol";
import { EquipmentTypes as t, EquipmentType } from "../equipment/EquipmentType.sol";
import { EquipmentAffixAvailabilityTargetIds as a } from "../equipment/EquipmentAffixAvailabilityTargetIds.sol";
import { AffixAvailabilityTargetId } from "../../affix/types.sol";
import { MAX_ILVL } from "../../affix/constants.sol";

library LibLootEquipment {
  error LibLootEquipment_InvalidIlvl(uint256 ilvl);
  error LibLootEquipment_InvalidWeights(W[] weights);

  /// @dev Hardcoded ilvl => AffixPartsIds mapping
  function getAffixPartIds(uint256 ilvl) internal pure returns (AffixPartId[] memory result) {
    if (ilvl == 0) {
      revert LibLootEquipment_InvalidIlvl(ilvl);
    } else if (ilvl <= 4) {
      result = new AffixPartId[](1);
      result[0] = AffixPartId.IMPLICIT;
    } else if (ilvl <= 8) {
      result = new AffixPartId[](2);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
    } else if (ilvl <= MAX_ILVL) {
      result = new AffixPartId[](3);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
    } else {
      revert LibLootEquipment_InvalidIlvl(ilvl);
    }
  }

  struct W {
    AffixAvailabilityTargetId targetId;
    EquipmentType equipmentType;
    uint256 weight;
  }

  /// @dev Randomly pick an equipment type.
  /// (Hardcoded ilvl => AffixAvailabilityTargetId,EquipmentType)
  function pickEquipmentTargetAndType(
    uint256 ilvl,
    uint256 randomness
  ) internal pure returns (AffixAvailabilityTargetId, EquipmentType) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickEquipmentTemplate"), randomness)));

    W[] memory w;

    if (ilvl == 0) {
      revert LibLootEquipment_InvalidIlvl(ilvl);
    } else if (ilvl <= 4) {
      w = new W[](5);
      w[0] = W(a.WEAPON, t.WEAPON, 32);
      w[1] = W(a.SHIELD, t.SHIELD, 16);
      w[2] = W(a.CLOTHING, t.CLOTHING, 32);
      w[3] = W(a.PANTS, t.PANTS, 16);
      w[4] = W(a.BOOTS, t.BOOTS, 16);
    } else if (ilvl <= 8) {
      w = new W[](7);
      w[0] = W(a.WEAPON, t.WEAPON, 32);
      w[1] = W(a.SHIELD, t.SHIELD, 32);
      w[2] = W(a.CLOTHING, t.CLOTHING, 32);
      w[3] = W(a.GLOVES, t.GLOVES, 16);
      w[4] = W(a.PANTS, t.PANTS, 32);
      w[5] = W(a.BOOTS, t.BOOTS, 32);
      w[6] = W(a.RING, t.RING, 4);
    } else if (ilvl <= MAX_ILVL) {
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
      revert LibLootEquipment_InvalidIlvl(ilvl);
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
