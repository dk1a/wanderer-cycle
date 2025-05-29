// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";
import { Entity } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/Entity.sol";
import { HasRole } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/HasRole.sol";

library LibSOFAccess {
  error LibSOFAccess_AccessDenied(uint256 entityId, address caller);

  function hasAccessRole(uint256 entityId, address caller) internal view returns (bool) {
    return HasRole.getIsMember(Entity.getAccessRole(entityId), caller);
  }

  function requireDirectAccessRole(uint256 entityId) internal view {
    IWorldWithContext world = IWorldWithContext(WorldContextConsumerLib._world());
    (, , address msgSender, ) = world.getWorldCallContext();

    if (!hasAccessRole(entityId, msgSender)) {
      revert LibSOFAccess_AccessDenied(entityId, msgSender);
    }
  }
}
