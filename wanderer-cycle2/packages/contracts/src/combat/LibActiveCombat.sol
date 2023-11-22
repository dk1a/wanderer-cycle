// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { ActiveCombat } from "../codegen/index.sol";

library LibActiveCombat {
  error LibActiveCombat__CombatActive();
  error LibActiveCombat__CombatNotActive();
  error LibActiveCombat__CombatActiveForDifferentRetaliator();

  function getRetaliatorEntity(bytes32 initiatorEntity) internal view returns (bytes32 retaliatorEntity) {
    if (ActiveCombat.get(initiatorEntity) == bytes32(0)) {
      revert LibActiveCombat__CombatNotActive();
    }
    return ActiveCombat.get(initiatorEntity);
  }

  function requireActiveCombat(bytes32 initiatorEntity, bytes32 retaliatorEntity) internal view {
    if (ActiveCombat.get(initiatorEntity) == bytes32(0)) {
      revert LibActiveCombat__CombatNotActive();
    }
    if (ActiveCombat.get(initiatorEntity) != retaliatorEntity) {
      revert LibActiveCombat__CombatActiveForDifferentRetaliator();
    }
  }

  function requireNotActiveCombat(bytes32 initiatorEntity) internal view {
    if (ActiveCombat.get(initiatorEntity) != bytes32(0)) {
      revert LibActiveCombat__CombatActive();
    }
  }
}