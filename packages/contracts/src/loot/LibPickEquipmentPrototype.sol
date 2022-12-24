// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { getEquipmentProtoEntity as epe } from "../equipment/EquipmentPrototypeComponent.sol";

library LibPickEquipmentPrototype {
  error LibPickEquipmentPrototype__InvalidIlvl();
  error LibPickEquipmentPrototype__InvalidWeights();

  /// @dev Randomly pick an equipment prototype.
  function pickEquipmentPrototype(
    uint256 ilvl,
    uint256 randomness
  ) internal pure returns (uint256) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickEquipmentPrototype"), randomness)));

    uint256[] memory b;
    uint256[] memory w;

    if (ilvl == 1) {
        b = new uint256[](5);
        w = new uint256[](5);
        b[0] = epe("Weapon");
        w[0] = 32;
        b[1] = epe("Shield");
        w[1] = 16;
        b[2] = epe("Clothing");
        w[2] = 32;
        b[3] = epe("Pants");
        w[3] = 16;
        b[4] = epe("Boots");
        w[4] = 16;
    } else if (ilvl == 2) {
        b = new uint256[](7);
        w = new uint256[](7);
        b[0] = epe("Weapon");
        w[0] = 32;
        b[1] = epe("Shield");
        w[1] = 32;
        b[2] = epe("Clothing");
        w[2] = 32;
        b[3] = epe("Gloves");
        w[3] = 16;
        b[4] = epe("Pants");
        w[4] = 32;
        b[5] = epe("Boots");
        w[5] = 32;
        b[6] = epe("Ring");
        w[6] = 4;
    } else if (ilvl >= 3) {
        b = new uint256[](9);
        w = new uint256[](9);
        b[0] = epe("Weapon");
        w[0] = 32;
        b[1] = epe("Shield");
        w[1] = 32;
        b[2] = epe("Hat");
        w[2] = 16;
        b[3] = epe("Clothing");
        w[3] = 32;
        b[4] = epe("Gloves");
        w[4] = 32;
        b[5] = epe("Pants");
        w[5] = 32;
        b[6] = epe("Boots");
        w[6] = 32;
        b[7] = epe("Amulet");
        w[7] = 4;
        b[8] = epe("Ring");
        w[8] = 8;
    } else {
      revert LibPickEquipmentPrototype__InvalidIlvl();
    }

    uint256 index = _sampleIndex(randomness, w);
    return b[index];
  }

  /// @dev Weighted sample.
  function _sampleIndex(
    uint256 randomness,
    uint256[] memory weights
  ) private pure returns (uint256) {
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
    revert LibPickEquipmentPrototype__InvalidWeights();
  }
}