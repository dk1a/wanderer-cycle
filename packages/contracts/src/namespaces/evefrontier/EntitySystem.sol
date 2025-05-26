// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";
import { ResourceIdInstance } from "@latticexyz/store/src/ResourceId.sol";

import { getUniqueEntity } from "@latticexyz/world-modules/src/modules/uniqueentity/getUniqueEntity.sol";

import { Entity, EntityData } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/Entity.sol";
import { EntityTagMap } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/EntityTagMap.sol";
import { Role } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/Role.sol";
import { HasRole } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/tables/HasRole.sol";

import { TagId, TagIdLib } from "@eveworld/smart-object-framework-v2/src/libs/TagId.sol";

import { TAG_TYPE_PROPERTY, TAG_TYPE_ENTITY_RELATION, TAG_TYPE_RESOURCE_RELATION, TAG_IDENTIFIER_CLASS, TAG_IDENTIFIER_OBJECT, TAG_IDENTIFIER_ENTITY_COUNT, TagParams, EntityRelationValue, ResourceRelationValue } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/systems/tag-system/types.sol";

import { tagSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/TagSystemLib.sol";
import { roleManagementSystem } from "@eveworld/smart-object-framework-v2/src/namespaces/evefrontier/codegen/systems/RoleManagementSystemLib.sol";

import { SmartObjectFramework } from "@eveworld/smart-object-framework-v2/src/inherit/SmartObjectFramework.sol";

/**
 * @dev Based on sof's EntitySystem, but returns class/object id, instead of accepting it as argument
 */
contract EntitySystem is SmartObjectFramework {
  error Entity_InvalidEntityId(uint256 entityId);
  error Entity_EntityAlreadyExists(uint256 entityId);
  error Entity_EntityDoesNotExist(uint256 classId);
  error Entity_PropertyTagNotFound(uint256 entityId, TagId tagId);
  error Entity_EntityRelationsFound(uint256 classId, uint256 numOfTags);
  error Entity_BadRoleConfirmation();
  error Entity_RoleDoesNotExist(bytes32 role);
  /**
   * Common TagIds for Entity management
   */
  TagId CLASS_PROPERTY_TAG = TagIdLib.encode(TAG_TYPE_PROPERTY, TAG_IDENTIFIER_CLASS);
  TagId OBJECT_PROPERTY_TAG = TagIdLib.encode(TAG_TYPE_PROPERTY, TAG_IDENTIFIER_OBJECT);
  TagId ENTITY_COUNT_PROPERTY_TAG = TagIdLib.encode(TAG_TYPE_PROPERTY, TAG_IDENTIFIER_ENTITY_COUNT);

  function registerClass(
    ResourceId[] memory scopedSystemIds
  ) public virtual context enforceCallCount(1) returns (uint256 classId) {
    classId = uint256(getUniqueEntity());
    _registerClass(classId, _callMsgSender(1), scopedSystemIds);
  }

  function instantiate(
    uint256 classId,
    address accessRoleMember
  ) public virtual context access(classId) returns (uint256 objectId) {
    objectId = uint256(getUniqueEntity());
    _instantiate(classId, objectId, accessRoleMember);
  }

  function addToScope(uint256 entityId, ResourceId[] memory scopedSystemIds) public virtual context access(entityId) {
    if (!Entity.getExists(entityId)) {
      revert Entity_EntityDoesNotExist(entityId);
    }

    _addToScope(entityId, scopedSystemIds);
  }

  /**
   * @notice Sets a new Class Access Role for a given Class Entity
   * @param classId A uint256 ID of an existing class Entity (An entity tagged with the class property tag)
   * @param newAccessRole A bytes32 access control role Id to be assigned to the class {see, RoleManagementSystem.sol}
   * @dev Validates `classId`, and `accessRole` existence
   * @dev Requires a direct caller to be a member of the current `accessRole`, or a System that is associated to the Class
   * @dev access configuration - only callable directly by a member of the Class access role or by a Class scoped System (see SOFAccessSystem.allowClassScopedSystemOrDirectAccessRole)
   */
  function setClassAccessRole(uint256 classId, bytes32 newAccessRole) public context access(classId) {
    if (!Entity.getExists(classId)) {
      revert Entity_EntityDoesNotExist(classId);
    }
    if (!EntityTagMap.getHasTag(classId, CLASS_PROPERTY_TAG)) {
      revert Entity_PropertyTagNotFound(classId, CLASS_PROPERTY_TAG);
    }
    if (!Role.getExists(newAccessRole)) {
      revert Entity_RoleDoesNotExist(newAccessRole);
    }
    Entity.setAccessRole(classId, newAccessRole);
  }

  /**
   * @notice Delete a registered Class
   * @param classId A uint256 ID of an existing class Entity (An entity tagged with the class property tag)
   * @dev Validates `classId` existence and class tag before executing
   * @dev Handles cleanup of property, entity, and associate resource tags
   * @dev Requires NO entity tags to be present (i.e., no objects to be tagged as inherting this class)
   * @dev Requires a direct call to the `deleteClass` function (cannot be called from another System)
   * @dev Requires caller to be a member of the `accessRole`
   * @dev Warning: Dependent data in relationally tagged entities and resources should be handled before deletion!
   * @dev access configuration - only callable directly by a member of the Class access role (see SOFAccessSystem.allowDirectAccessRole)
   */
  function deleteClass(uint256 classId) public context access(classId) {
    if (!Entity.getExists(classId)) {
      revert Entity_EntityDoesNotExist(classId);
    }
    if (!EntityTagMap.getHasTag(classId, CLASS_PROPERTY_TAG)) {
      revert Entity_PropertyTagNotFound(classId, CLASS_PROPERTY_TAG);
    }

    EntityData memory class = Entity.get(classId);

    uint256 numberOfDependentEntities = abi.decode(
      EntityTagMap.getValue(classId, ENTITY_COUNT_PROPERTY_TAG),
      (uint256)
    );
    if (numberOfDependentEntities > 0) {
      revert Entity_EntityRelationsFound(classId, numberOfDependentEntities);
    }

    // delete the class access role data
    bytes32 classAccessRole = keccak256(abi.encodePacked("ACCESS_ROLE", classId));
    roleManagementSystem.scopedRevokeAll(classId, classAccessRole);
    Role.deleteRecord(classAccessRole);

    // remove all tags attached to this class
    TagId[] memory propertyTagIds = new TagId[](class.propertyTags.length);
    for (uint i = 0; i < class.propertyTags.length; i++) {
      propertyTagIds[i] = TagId.wrap(class.propertyTags[i]);
    }
    if (propertyTagIds.length > 0) {
      tagSystem.removeTags(classId, propertyTagIds);
    }

    TagId[] memory resourceRelationTagIds = new TagId[](class.resourceRelationTags.length);
    for (uint i = 0; i < class.resourceRelationTags.length; i++) {
      resourceRelationTagIds[i] = TagId.wrap(class.resourceRelationTags[i]);
    }
    if (resourceRelationTagIds.length > 0) {
      tagSystem.removeTags(classId, resourceRelationTagIds);
    }

    // delete the class entity
    Entity.deleteRecord(classId);
  }

  /**
   * @notice Deletes multiple registered Classes
   * @param classIds An array of uint256 IDs of existing class tagged Entities
   * @dev Iteratively calls deleteClass for each classId in `classIds`
   */
  function deleteClasses(uint256[] memory classIds) public {
    for (uint i = 0; i < classIds.length; i++) {
      deleteClass(classIds[i]);
    }
  }

  /**
   * @notice Sets a new Object Access Role for a given Object
   * @param objectId A uint256 ID of an existing object Entity
   * @param newAccessRole A bytes32 access control role Id to be assigned to the object {see, RoleManagementSystem.sol}
   * @dev Validates `objectId` existence, and `newAccessRole` existence
   * @dev access configuration - only callable directly by a member of the Object Access role or by a Class scoped System (see SOFAccessSystem.allowClassScopedSystemOrDirectAccessRole)
   */
  function setObjectAccessRole(uint256 objectId, bytes32 newAccessRole) public context access(objectId) {
    if (!Entity.getExists(objectId)) {
      revert Entity_EntityDoesNotExist(objectId);
    }
    if (!EntityTagMap.getHasTag(objectId, OBJECT_PROPERTY_TAG)) {
      revert Entity_PropertyTagNotFound(objectId, OBJECT_PROPERTY_TAG);
    }
    if (!Role.getExists(newAccessRole)) {
      revert Entity_RoleDoesNotExist(newAccessRole);
    }
    Entity.setAccessRole(objectId, newAccessRole);
  }

  /**
   * @notice Delete an instantiated Object
   * @param objectId A uint256 ID of an existing object Entity
   * @dev Handles cleanup of object property, entity, and associated resource tags
   * @dev Requires a direct caller to be a member of the Object's parent Class `accessRole` or a System that is associated with the Object's parent Class
   * @dev Warning: Dependent data in associated entities and resources should be handled before deletion!
   * @dev access configuration - only callable directly by a member of the object's Class access role or by Class scoped System (see SOFAccessSystem.allowClassScopedSystemOrDirectClassAccessRole)
   */
  function deleteObject(uint256 objectId) public context access(objectId) {
    if (!Entity.getExists(objectId)) {
      revert Entity_EntityDoesNotExist(objectId);
    }

    EntityData memory object = Entity.get(objectId);

    // decrement the count for the parent class entity relation value
    EntityRelationValue memory objectEntityRelationValue = abi.decode(
      EntityTagMap.getValue(objectId, TagIdLib.encode(TAG_TYPE_ENTITY_RELATION, bytes30(bytes32(objectId)))),
      (EntityRelationValue)
    );
    uint256 numberOfDependentEntities = abi.decode(
      EntityTagMap.getValue(objectEntityRelationValue.relatedEntityId, ENTITY_COUNT_PROPERTY_TAG),
      (uint256)
    );
    EntityTagMap.setValue(
      objectEntityRelationValue.relatedEntityId,
      ENTITY_COUNT_PROPERTY_TAG,
      abi.encode(numberOfDependentEntities - 1)
    );

    // remove all tags attached to this object
    tagSystem.removeTag(objectId, object.entityRelationTag);

    TagId[] memory propertyTagIds = new TagId[](object.propertyTags.length);
    for (uint i = 0; i < object.propertyTags.length; i++) {
      propertyTagIds[i] = TagId.wrap(object.propertyTags[i]);
    }
    if (propertyTagIds.length > 0) {
      tagSystem.removeTags(objectId, propertyTagIds);
    }

    TagId[] memory resourceRelationTagIds = new TagId[](object.resourceRelationTags.length);
    for (uint i = 0; i < object.resourceRelationTags.length; i++) {
      resourceRelationTagIds[i] = TagId.wrap(object.resourceRelationTags[i]);
    }
    if (resourceRelationTagIds.length > 0) {
      tagSystem.removeTags(objectId, resourceRelationTagIds);
    }

    // delete the object access role data
    bytes32 objectAccessRole = keccak256(abi.encodePacked("ACCESS_ROLE", objectId));

    // scoped to `classid` because this function is only callable directly by a member of the object's class access role
    roleManagementSystem.scopedRevokeAll(objectEntityRelationValue.relatedEntityId, objectAccessRole);

    Role.deleteRecord(objectAccessRole);

    Entity.deleteRecord(objectId);
  }

  /**
   * @notice Deletes multiple instantiated Objects
   * @param objectIds An array of uint256 IDs of existing object tagged Entities
   * @dev Iteratively calls deleteObject for each objectId in `objectIds`
   */
  function deleteObjects(uint256[] memory objectIds) public {
    for (uint i = 0; i < objectIds.length; i++) {
      deleteObject(objectIds[i]);
    }
  }

  function _addToScope(uint256 entityId, ResourceId[] memory scopedSystemIds) internal {
    TagParams[] memory systemResourceTags = new TagParams[](scopedSystemIds.length);
    for (uint i = 0; i < scopedSystemIds.length; i++) {
      systemResourceTags[i] = TagParams(
        TagIdLib.encode(TAG_TYPE_RESOURCE_RELATION, bytes30(ResourceId.unwrap(scopedSystemIds[i]))),
        abi.encode(
          ResourceRelationValue("COMPOSITION", RESOURCE_SYSTEM, ResourceIdInstance.getResourceName(scopedSystemIds[i]))
        )
      );
    }
    if (systemResourceTags.length > 0) {
      tagSystem.setTags(entityId, systemResourceTags);
    }
  }

  function _registerClass(uint256 classId, address accessRoleMember, ResourceId[] memory scopedSystemIds) internal {
    if (classId == uint256(0)) {
      revert Entity_InvalidEntityId(classId);
    }
    if (Entity.getExists(classId)) {
      revert Entity_EntityAlreadyExists(classId);
    }

    bytes32 classAccessRole = keccak256(abi.encodePacked("ACCESS_ROLE", classId));

    roleManagementSystem.scopedCreateRole(0, classAccessRole, classAccessRole, accessRoleMember);

    Entity.set(classId, true, classAccessRole, TagId.wrap(bytes32(0)), new bytes32[](0), new bytes32[](0));

    TagParams[] memory propertyTags = new TagParams[](2);
    propertyTags[0] = TagParams(CLASS_PROPERTY_TAG, bytes(""));
    propertyTags[1] = TagParams(ENTITY_COUNT_PROPERTY_TAG, abi.encode(uint256(0)));

    tagSystem.setTags(classId, propertyTags);

    _addToScope(classId, scopedSystemIds);
  }

  function _instantiate(uint256 classId, uint256 objectId, address accessRoleMember) internal {
    if (!Entity.getExists(classId)) {
      revert Entity_EntityDoesNotExist(classId);
    }
    if (!EntityTagMap.getHasTag(classId, CLASS_PROPERTY_TAG)) {
      revert Entity_PropertyTagNotFound(classId, CLASS_PROPERTY_TAG);
    }

    if (objectId == uint256(0)) {
      revert Entity_InvalidEntityId(objectId);
    }

    if (Entity.getExists(objectId)) {
      revert Entity_EntityAlreadyExists(objectId);
    }

    bytes32 objectAccessRole = keccak256(abi.encodePacked("ACCESS_ROLE", objectId));

    roleManagementSystem.scopedCreateRole(classId, objectAccessRole, objectAccessRole, accessRoleMember);

    Entity.set(objectId, true, objectAccessRole, TagId.wrap(bytes32(0)), new bytes32[](0), new bytes32[](0));

    // increment the count for the parent class entity relation value
    uint256 numberOfDependentEntities = abi.decode(
      EntityTagMap.getValue(classId, ENTITY_COUNT_PROPERTY_TAG),
      (uint256)
    );
    EntityTagMap.setValue(classId, ENTITY_COUNT_PROPERTY_TAG, abi.encode(numberOfDependentEntities + 1));

    // set the object tags
    TagId inheritanceTagId = TagIdLib.encode(TAG_TYPE_ENTITY_RELATION, bytes30(bytes32(objectId)));
    TagParams memory entityRelationTag = TagParams(
      inheritanceTagId,
      abi.encode(EntityRelationValue("INHERITANCE", classId))
    );

    tagSystem.setTag(objectId, entityRelationTag);

    TagParams memory propertyTag = TagParams(OBJECT_PROPERTY_TAG, bytes(""));

    tagSystem.setTag(objectId, propertyTag);
  }
}
