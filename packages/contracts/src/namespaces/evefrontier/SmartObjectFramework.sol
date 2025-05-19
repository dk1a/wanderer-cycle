// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";
import { SmartObjectFramework as _SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";

import { LibSOFAccess } from "./LibSOFAccess.sol";

contract SmartObjectFramework is _SmartObjectFramework {
  // TODO refactor the 2 funcs when you come up with something better, especially names
  function _requireEntityBranch(uint256 entityId) internal view {
    _enforceScope(entityId);

    uint256 callCount = IWorldWithContext(_world()).getWorldCallCount();
    if (callCount == 1) {
      LibSOFAccess.requireDirectAccessRole(entityId);
    }
  }

  function _requireEntityLeaf(uint256 entityId) internal view {
    _enforceScope(entityId);

    uint256 callCount = IWorldWithContext(_world()).getWorldCallCount();
    if (callCount > 1) {
      (ResourceId prevSystemId, , , ) = IWorldWithContext(_world()).getWorldCallContext(callCount - 1);
      _scope(entityId, prevSystemId);
    } else if (callCount == 1) {
      LibSOFAccess.requireDirectAccessRole(entityId);
    }
  }

  function _enforceScope(uint256 entityId) internal view {
    // check that the current system is in scope for the given entity
    {
      ResourceId systemId = SystemRegistry.get(address(this));
      _scope(entityId, systemId);
      // if this is a subsequent system-to-system call (callCount > 1), then check that the previous (calling) system is in scope for the given entity
      uint256 callCount = IWorldWithContext(_world()).getWorldCallCount();
      if (callCount > 1) {
        (ResourceId prevSystemId, , , ) = IWorldWithContext(_world()).getWorldCallContext(callCount - 1);
        _scope(entityId, prevSystemId);
      }
    }
  }
}
