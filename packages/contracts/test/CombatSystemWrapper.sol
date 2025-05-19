// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { System } from "@latticexyz/world/src/System.sol";

import { combatSystem, CombatAction, CombatResult } from "../src/namespaces/combat/codegen/systems/CombatSystemLib.sol";

contract CombatSystemWrapper is System {
  function actPVERound(
    bytes32 combatEntity,
    CombatAction[] memory initiatorActions,
    CombatAction[] memory retaliatorActions
  ) public returns (CombatResult result) {
    return combatSystem.actPVERound(combatEntity, initiatorActions, retaliatorActions);
  }
}

library CombatSystemWrapperLib {
  function _systemId() internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode(RESOURCE_SYSTEM, "cycle", "CombatSystemWrap");
  }

  function _systemIdUnscoped() internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode(RESOURCE_SYSTEM, "cycle", "CombatSystemWUns");
  }

  function _world() internal view returns (IBaseWorld) {
    return IBaseWorld(StoreSwitch.getStoreAddress());
  }

  function registerSystem() internal {
    _world().registerSystem(_systemId(), new CombatSystemWrapper(), true);
  }

  function registerSystemUnscoped() internal {
    _world().registerSystem(_systemIdUnscoped(), new CombatSystemWrapper(), false);
  }

  function actPVERound(
    bytes32 combatEntity,
    CombatAction[] memory initiatorActions,
    CombatAction[] memory retaliatorActions
  ) internal returns (CombatResult) {
    return _actPVERound(_systemId(), combatEntity, initiatorActions, retaliatorActions);
  }

  function _actPVERound(
    ResourceId systemId,
    bytes32 combatEntity,
    CombatAction[] memory initiatorActions,
    CombatAction[] memory retaliatorActions
  ) internal returns (CombatResult result) {
    bytes memory systemCall = abi.encodeCall(
      CombatSystemWrapper.actPVERound,
      (combatEntity, initiatorActions, retaliatorActions)
    );

    bytes memory _result = _world().call(systemId, systemCall);
    if (_result.length != 0) {
      return abi.decode(_result, (CombatResult));
    }
  }
}

library CombatSystemWrapperUnscopedLib {
  function _systemId() internal pure returns (ResourceId) {
    return WorldResourceIdLib.encode(RESOURCE_SYSTEM, "cycle", "CombatSystemWUns");
  }

  function _world() internal view returns (IBaseWorld) {
    return IBaseWorld(StoreSwitch.getStoreAddress());
  }

  function registerSystem() internal {
    _world().registerSystem(_systemId(), new CombatSystemWrapper(), true);
  }

  function actPVERound(
    bytes32 combatEntity,
    CombatAction[] memory initiatorActions,
    CombatAction[] memory retaliatorActions
  ) internal returns (CombatResult) {
    return CombatSystemWrapperLib._actPVERound(_systemId(), combatEntity, initiatorActions, retaliatorActions);
  }
}
