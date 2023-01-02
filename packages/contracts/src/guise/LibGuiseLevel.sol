// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveGuiseComponent, ID as ActiveGuiseComponentID } from "./ActiveGuiseComponent.sol";
import { GuisePrototypeComponent, ID as GuisePrototypeComponentID } from "./GuisePrototypeComponent.sol";

import { LibExperience, PS_L } from "../charstat/LibExperience.sol";

library LibGuiseLevel {
  using LibExperience for LibExperience.Self;

  /// @dev Get target's aggregate level using its guise's level multipliers.
  /// (aggregate level means all primary stats aggregated together)
  function getAggregateLevel(
    IUint256Component components,
    uint256 targetEntity
  ) internal view returns (uint32) {
    ActiveGuiseComponent activeGuiseComp = ActiveGuiseComponent(getAddressById(components, ActiveGuiseComponentID));
    GuisePrototypeComponent guiseProto = GuisePrototypeComponent(getAddressById(components, GuisePrototypeComponentID));
    LibExperience.Self memory exp = LibExperience.__construct(components, targetEntity);

    uint256 guiseProtoEntity = activeGuiseComp.getValue(targetEntity);
    uint32[PS_L] memory levelMul = guiseProto.getValue(guiseProtoEntity).levelMul;
    return exp.getAggregateLevel(levelMul);
  }
}