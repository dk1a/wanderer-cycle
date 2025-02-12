// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixPartId } from "../../../codegen/common.sol";
import { EquipmentTypes, EquipmentType } from "../equipment/EquipmentType.sol";

library LibLootEquipment {
  error LibLootEquipment__InvalidIlvl();
  error LibLootEquipment__InvalidWeights();

  /// @dev Hardcoded ilvl => AffixPartsIds mapping
  function getAffixPartIds(uint256 ilvl) internal pure returns (AffixPartId[] memory result) {
    if (ilvl == 0) {
      revert LibLootEquipment__InvalidIlvl();
    } else if (ilvl <= 4) {
      result = new AffixPartId[](1);
      result[0] = AffixPartId.IMPLICIT;
    } else if (ilvl <= 8) {
      result = new AffixPartId[](2);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
    } else if (ilvl <= 12) {
      result = new AffixPartId[](3);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
    } else {
      revert LibLootEquipment__InvalidIlvl();
    }
  }

  /// @dev Randomly pick an equipment type.
  /// (Hardcoded ilvl => EquipmentType)
  function pickEquipmentType(uint256 ilvl, uint256 randomness) internal pure returns (EquipmentType) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickEquipmentTemplate"), randomness)));

    EquipmentType[] memory b;
    uint256[] memory w;

    if (ilvl == 0) {
      revert LibLootEquipment__InvalidIlvl();
    } else if (ilvl <= 4) {
      b = new EquipmentType[](5);
      w = new uint256[](5);
      b[0] = EquipmentTypes.WEAPON;
      w[0] = 32;
      b[1] = EquipmentTypes.SHIELD;
      w[1] = 16;
      b[2] = EquipmentTypes.CLOTHING;
      w[2] = 32;
      b[3] = EquipmentTypes.PANTS;
      w[3] = 16;
      b[4] = EquipmentTypes.BOOTS;
      w[4] = 16;
    } else if (ilvl <= 8) {
      b = new EquipmentType[](7);
      w = new uint256[](7);
      b[0] = EquipmentTypes.WEAPON;
      w[0] = 32;
      b[1] = EquipmentTypes.SHIELD;
      w[1] = 32;
      b[2] = EquipmentTypes.CLOTHING;
      w[2] = 32;
      b[3] = EquipmentTypes.GLOVES;
      w[3] = 16;
      b[4] = EquipmentTypes.PANTS;
      w[4] = 32;
      b[5] = EquipmentTypes.BOOTS;
      w[5] = 32;
      b[6] = EquipmentTypes.RING;
      w[6] = 4;
    } else if (ilvl <= 16) {
      b = new EquipmentType[](9);
      w = new uint256[](9);
      b[0] = EquipmentTypes.WEAPON;
      w[0] = 32;
      b[1] = EquipmentTypes.SHIELD;
      w[1] = 32;
      b[2] = EquipmentTypes.HAT;
      w[2] = 16;
      b[3] = EquipmentTypes.CLOTHING;
      w[3] = 32;
      b[4] = EquipmentTypes.GLOVES;
      w[4] = 32;
      b[5] = EquipmentTypes.PANTS;
      w[5] = 32;
      b[6] = EquipmentTypes.BOOTS;
      w[6] = 32;
      b[7] = EquipmentTypes.AMULET;
      w[7] = 4;
      b[8] = EquipmentTypes.RING;
      w[8] = 8;
    } else {
      revert LibLootEquipment__InvalidIlvl();
    }

    uint256 index = _sampleIndex(randomness, w);
    return b[index];
  }

  /// @dev Weighted sample.
  function _sampleIndex(uint256 randomness, uint256[] memory weights) private pure returns (uint256) {
    uint256 totalWeight;
    for (uint256 i; i < weights.length; i++) {
      totalWeight += weights[i];
    }
    uint256 roll = randomness % totalWeight;
    for (uint256 i; i < weights.length; i++) {
      totalWeight -= weights[i];
      if (roll >= totalWeight) {
        return i;
      }
    }
    revert LibLootEquipment__InvalidWeights();
  }
}
