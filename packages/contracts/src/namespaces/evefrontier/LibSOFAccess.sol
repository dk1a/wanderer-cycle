// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";
import { SystemRegistry } from "@latticexyz/world/src/codegen/tables/SystemRegistry.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";
import { Entity } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/Entity.sol";
import { EntityTagMap } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/EntityTagMap.sol";
import { HasRole } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/HasRole.sol";
import { TagId, TagIdLib } from "@eveworld/smart-object-framework-v2/src/libs/TagId.sol";
import { EntityRelationValue, TAG_TYPE_PROPERTY, TAG_TYPE_ENTITY_RELATION, TAG_TYPE_RESOURCE_RELATION, TAG_IDENTIFIER_CLASS } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/systems/tag-system/types.sol";

library LibSOFAccess {
  error LibSOFAccess_AccessDenied(uint256 entityId, address caller);

  function isEntityScoped(uint256 entityId, ResourceId systemId) internal view returns (bool) {
    // TODO decide what to do with non-class scoped entities?
    TagId systemTagId = TagIdLib.encode(TAG_TYPE_RESOURCE_RELATION, bytes30(ResourceId.unwrap(systemId)));
    return EntityTagMap.getHasTag(entityId, systemTagId);
  }

  function hasAccessRole(uint256 entityId, address caller) internal view returns (bool) {
    return HasRole.getIsMember(Entity.getAccessRole(entityId), caller);
  }

  function getClassId(uint256 entityId) internal view returns (uint256) {
    uint256 classId;
    if (entityId != 0) {
      // entityRelationValue requires an entry in EntityTagMap and entityId 0 cannot have an entry
      if (EntityTagMap.getHasTag(entityId, TagIdLib.encode(TAG_TYPE_PROPERTY, TAG_IDENTIFIER_CLASS))) {
        classId = entityId;
      } else {
        EntityRelationValue memory entityRelationValue = abi.decode(
          EntityTagMap.getValue(entityId, TagIdLib.encode(TAG_TYPE_ENTITY_RELATION, bytes30(bytes32(entityId)))),
          (EntityRelationValue)
        );
        classId = entityRelationValue.relatedEntityId;
      }
    }
    return classId;
  }

  function requireDirectAccessRole(uint256 entityId) internal view {
    IWorldWithContext world = IWorldWithContext(WorldContextConsumerLib._world());
    (, , address msgSender, ) = world.getWorldCallContext();

    if (!hasAccessRole(entityId, msgSender)) {
      revert LibSOFAccess_AccessDenied(entityId, msgSender);
    }
  }

  /*function requireClassScopedSystemOrDirectAccessRole(uint256 entityId) internal view {
    IWorldWithContext world = IWorldWithContext(WorldContextConsumerLib._world());
    uint256 classId = getClassId(entityId);
    uint256 callCount = world.getWorldCallCount();
    (, , address msgSender, ) = world.getWorldCallContext(callCount);
    ResourceId callingSystemId = SystemRegistry.get(msgSender);

    if (callCount > 1 && isEntityScoped(classId, callingSystemId)) {
      // system-to-system call case
      return;
    } else if (callCount == 1 && hasAccessRole(entityId, msgSender)) {
      // entry point direct call case
      return;
    }

    revert LibSOFAccess_AccessDenied(entityId, msgSender);
  }

  function requireEntityScopedSystemOrDirectAccessRole(uint256 entityId) internal view {
    IWorldWithContext world = IWorldWithContext(WorldContextConsumerLib._world());
    uint256 callCount = world.getWorldCallCount();
    (, , address msgSender, ) = world.getWorldCallContext(callCount);
    ResourceId callingSystemId = SystemRegistry.get(msgSender);

    if (callCount > 1 && (isEntityScoped(entityId, callingSystemId) || isEntityScoped(getClassId(entityId), callingSystemId))) {
      // system-to-system call case
      return;
    } else if (callCount == 1 && hasAccessRole(entityId, msgSender)) {
      // entry point direct call case
      return;
    }

    revert LibSOFAccess_AccessDenied(entityId, msgSender);
  }*/
}
