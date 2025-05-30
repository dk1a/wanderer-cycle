// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";
import { SmartObjectFramework as _SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";

import { LibSOFAccess } from "./LibSOFAccess.sol";

contract SmartObjectFramework is _SmartObjectFramework {
  function _requireEntityLeaf(bytes32 entityId) internal view {
    uint256 callCount = IWorldWithContext(_world()).getWorldCallCount();
    if (callCount > 1) {
      (ResourceId prevSystemId, , , ) = IWorldWithContext(_world()).getWorldCallContext(callCount - 1);
      _scope(uint256(entityId), prevSystemId);
    } else if (callCount == 1) {
      LibSOFAccess.requireDirectAccessRole(uint256(entityId));
    }
  }

  function _requireEntityBranch(bytes32 entityId) internal view {
    _enforceScope(uint256(entityId));

    uint256 callCount = IWorldWithContext(_world()).getWorldCallCount();
    if (callCount == 1) {
      LibSOFAccess.requireDirectAccessRole(uint256(entityId));
    }
  }

  function _requireEntityRoot(bytes32 entityId) internal view {
    ResourceId systemId = SystemRegistry.get(address(this));
    _scope(uint256(entityId), systemId);
  }
}
