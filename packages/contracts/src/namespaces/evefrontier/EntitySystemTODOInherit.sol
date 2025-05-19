// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";

// TODO consider making unique entity functionality a direct part of this system, without the module
import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { EntitySystem as _EntitySystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/systems/entity-system/EntitySystem.sol";

/**
 * @dev Based on sof's EntitySystem, but returns class/object ids, instead of accepting them as arguments
 */
contract EntitySystemTODOInherit is _EntitySystem {
  error Entity_MethodNotSupported();

  /*
  // TODO consider ditching enforceCallCount
  function registerClass(ResourceId[] memory scopedSystemIds) public virtual context enforceCallCount(1) returns (uint256 classId) {
    classId = uint256(getUniqueEntity());
    _registerClass(classId, _callMsgSender(1), scopedSystemIds);
  }

  function instantiate(uint256 classId, address accessRoleMember) public virtual context access(classId) returns (uint256 objectId) {
    objectId = uint256(getUniqueEntity());
    _instantiate(classId, objectId, accessRoleMember);
  }

  function registerClass(uint256, ResourceId[] memory) public virtual override {
    revert Entity_MethodNotSupported();
  }

  function scopedRegisterClass(uint256, address, ResourceId[] memory) public virtual override {
    revert Entity_MethodNotSupported();
  }

  function instantiate(uint256, uint256, address) public virtual override {
    revert Entity_MethodNotSupported();
  }
  */
}
