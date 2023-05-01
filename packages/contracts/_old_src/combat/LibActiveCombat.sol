// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { ActiveCombatComponent, ID as ActiveCombatComponentID } from "./ActiveCombatComponent.sol";

library LibActiveCombat {
  error LibActiveCombat__CombatActive();
  error LibActiveCombat__CombatNotActive();
  error LibActiveCombat__CombatActiveForDifferentRetaliator();

  function getRetaliatorEntity(
    IUint256Component components,
    uint256 initiatorEntity
  ) internal view returns (uint256 retaliatorEntity) {
    ActiveCombatComponent activeCombatComp = _comp(components);
    if (!activeCombatComp.has(initiatorEntity)) {
      revert LibActiveCombat__CombatNotActive();
    }
    return activeCombatComp.getValue(initiatorEntity);
  }

  function requireActiveCombat(
    IUint256Component components,
    uint256 initiatorEntity,
    uint256 retaliatorEntity
  ) internal view {
    ActiveCombatComponent activeCombatComp = _comp(components);
    if (!activeCombatComp.has(initiatorEntity)) {
      revert LibActiveCombat__CombatNotActive();
    }
    if (activeCombatComp.getValue(initiatorEntity) != retaliatorEntity) {
      revert LibActiveCombat__CombatActiveForDifferentRetaliator();
    }
  }

  function requireNotActiveCombat(IUint256Component components, uint256 initiatorEntity) internal view {
    if (_comp(components).has(initiatorEntity)) {
      revert LibActiveCombat__CombatActive();
    }
  }

  function _comp(IUint256Component components) internal view returns (ActiveCombatComponent) {
    return ActiveCombatComponent(getAddressById(components, ActiveCombatComponentID));
  }
}
