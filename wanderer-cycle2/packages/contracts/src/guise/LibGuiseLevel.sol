// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ActiveGuise, GuisePrototype } from "../codegen/index.sol";

import { PStat_length } from "../CustomTypes.sol";
import { LibExperience } from "../charstat/LibExperience.sol";

library LibGuiseLevel {
  /// @dev Get target's aggregate level using its guise's level multipliers.
  /// (aggregate level means all primary stats aggregated together)
  function getAggregateLevel(bytes32 targetEntity) internal view returns (uint32) {
    bytes32 guiseProtoEntity = ActiveGuise.get(targetEntity);
    uint32[PStat_length] memory levelMul = GuisePrototype.get(guiseProtoEntity);
    return LibExperience.getAggregateLevel(targetEntity, levelMul);
  }

  /// @dev Multiply gained experience by guise's level multiplier
  function multiplyExperience(
    bytes32 targetEntity,
    uint32[PStat_length] memory exp
  ) internal view returns (uint32[PStat_length] memory expMultiplied) {
    bytes32 guiseProtoEntity = ActiveGuise.get(targetEntity);
    uint32[PStat_length] memory levelMul = GuisePrototype.get(guiseProtoEntity);

    for (uint256 i; i < PStat_length; i++) {
      expMultiplied[i] = exp[i] * levelMul[i];
    }
    return expMultiplied;
  }
}