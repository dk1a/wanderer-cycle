// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { WorldContextConsumerLib } from "@latticexyz/world/src/WorldContext.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";
import { roleManagementSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/RoleManagementSystemLib.sol";
import { Entity } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/Entity.sol";

import { UniqueIdx_SOFClassName_Name } from "./codegen/idxs/UniqueIdx_SOFClassName_Name.sol";
import { entitySystem } from "../evefrontier/codegen/systems/EntitySystemLib.sol";

library LibSOFClass {
  error LibSOFClass_NameNotFound(string name);

  function getClassId(string memory name) internal view returns (bytes32 classId) {
    classId = UniqueIdx_SOFClassName_Name.get(name);
    if (classId == bytes32(0)) {
      revert LibSOFClass_NameNotFound(name);
    }
  }

  function instantiate(string memory name, address accessRoleMember) internal returns (bytes32 objectId) {
    bytes32 classId = getClassId(name);
    objectId = bytes32(entitySystem.instantiate(uint256(classId), accessRoleMember));
  }

  // Entities may have custom access control for objects, so the role should be burned
  function instantiate(string memory name) internal returns (bytes32 objectId) {
    bytes32 classId = getClassId(name);
    address self = address(this);
    objectId = bytes32(entitySystem.instantiate(uint256(classId), self));
    scopedRenounceRole(objectId);
  }

  function scopedRenounceRole(bytes32 objectId) internal {
    // This is just a magic confirmation requirement, see scopedRenounceRole
    (, , address initialMsgSender, ) = IWorldWithContext(WorldContextConsumerLib._world()).getWorldCallContext(1);

    roleManagementSystem.scopedRenounceRole(
      uint256(objectId),
      Entity.getAccessRole(uint256(objectId)),
      initialMsgSender
    );
  }

  // Instantiate an object without an owner, but with an entity-level scope using the provided system ids
  // TODO consider alternatives, whether you want to separate class/object checks, and add a better description
  function instantiate(string memory name, ResourceId[] memory scopedSystemIds) internal returns (bytes32 objectId) {
    objectId = instantiate(name);
    entitySystem.addToScope(uint256(objectId), scopedSystemIds);
  }
}
