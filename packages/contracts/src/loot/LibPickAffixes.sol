// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "@latticexyz/solecs/src/interfaces/IWorld.sol";
import { IUint256Component } from "@latticexyz/solecs/src/interfaces/IUint256Component.sol";
import { getAddressById } from "@latticexyz/solecs/src/utils.sol";

import {
  getAffixAvailabilityEntity,
  AffixAvailabilityComponent,
  ID as AffixAvailabilityComponentID
} from "./AffixAvailabilityComponent.sol";
import {
  AffixPrototype,
  AffixPrototypeComponent,
  ID as AffixPrototypeComponentID
} from "./AffixPrototypeComponent.sol";
import { AffixPrototypeGroupComponent, ID as AffixPrototypeGroupComponentID } from "./AffixPrototypeGroupComponent.sol";
import { AffixPartId } from "./AffixNamingComponent.sol";

library LibPickAffixes {
  error LibPickAffixes__NoAvailableAffix(uint256 ilvl, AffixPartId affixPartId, uint256 equipmentProtoEntity);
  error LibPickAffixes__InvalidMinMax();
  error LibPickAffixes__InvalidIlvl(uint256 ilvl);

  struct Comps {
    AffixPrototypeComponent affixProto;
    AffixAvailabilityComponent availability;
    AffixPrototypeGroupComponent group;
  }

  function pickAffixes(
    IUint256Component components,
    uint256 equipmentProtoEntity,
    uint256 ilvl,
    uint256 randomness
  ) internal view returns (
    uint256[] memory statmodProtoEntities,
    uint256[] memory affixProtoEntities,
    uint256[] memory affixValues
  ) {
    Comps memory comps = Comps(
      AffixPrototypeComponent(getAddressById(components, AffixPrototypeComponentID)),
      AffixAvailabilityComponent(getAddressById(components, AffixAvailabilityComponentID)),
      AffixPrototypeGroupComponent(getAddressById(components, AffixPrototypeGroupComponentID))
    );

    uint256[] memory excludeAffixes;
    AffixPartId[] memory affixPartIds = _getAffixPartIds(ilvl);

    statmodProtoEntities = new uint256[](affixPartIds.length);
    affixProtoEntities = new uint256[](affixPartIds.length);
    affixValues = new uint256[](affixPartIds.length);

    for (uint256 i; i < affixPartIds.length; i++) {
      randomness = uint256(keccak256(abi.encode(i, randomness)));
      // pick affix proto entity
      uint256 affixProtoEntity = _pickAffixProtoEntity(
        comps,
        ilvl,
        affixPartIds[i],
        equipmentProtoEntity,
        excludeAffixes,
        randomness
      );
      AffixPrototype memory affixProto = comps.affixProto.getValue(affixProtoEntity);
      // set the corresponding statmod
      statmodProtoEntities[i] = affixProto.statmodProtoEntity;

      // pick its value
      affixProtoEntities[i] = affixProtoEntity;
      affixValues[i] = _pickAffixValue(affixProto, randomness);

      if (i != affixPartIds.length - 1) {
        // exclude all affixes from the picked affix's group (skip for the last cycle)
        uint256[] memory newExcludeAffixes = comps.group.getEntitiesWithValue(
          comps.group.getValue(affixProtoEntity)
        );
        excludeAffixes = _concatArrays(excludeAffixes, newExcludeAffixes);
      }
    }
  }

  /// @dev Randomly pick an affix entity from the available set.
  function _pickAffixProtoEntity(
    Comps memory comps,
    uint256 ilvl,
    AffixPartId affixPartId,
    uint256 equipmentProtoEntity,
    uint256[] memory excludeAffixes,
    uint256 randomness
  ) internal view returns (uint256) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickAffixEntity"), randomness)));

    // TODO this can be significantly optimized if you need it
    uint256 availabilityEntity = getAffixAvailabilityEntity(ilvl, affixPartId, equipmentProtoEntity);
    uint256[] memory entities = _getAvailableEntities(comps, availabilityEntity, excludeAffixes);
    if (entities.length == 0) revert LibPickAffixes__NoAvailableAffix(ilvl, affixPartId, equipmentProtoEntity);

    uint256 index = randomness % entities.length;
    return entities[index];
  }

  /// @dev Queries the default availability and removes `excludeEntities` from it.
  function _getAvailableEntities(
    Comps memory comps,
    uint256 availabilityEntity,
    uint256[] memory excludeEntities
  ) private view returns (uint256[] memory availableEntities) {
    // get default availability
    availableEntities = comps.availability.getValue(availabilityEntity);

    for (uint256 i; i < availableEntities.length; i++) {
      // exclude the specified entities
      if (_isIn(availableEntities[i], excludeEntities)) {
        uint256 len = availableEntities.length;
        // swap and pop
        availableEntities[i] = availableEntities[len - 1];
        /// @solidity memory-safe-assembly
        assembly {
          // shorten the array length
          mstore(availableEntities, sub(len, 1))
        }
      }
    }
    return availableEntities;
  }

  /// @dev Randomly pick an affix value.
  function _pickAffixValue(
    AffixPrototype memory affixProto,
    uint256 randomness
  ) internal pure returns (uint256) {
    randomness = uint256(keccak256(abi.encode(keccak256("_pickAffixValue"), randomness)));

    if (affixProto.max < affixProto.min) revert LibPickAffixes__InvalidMinMax();
    if (affixProto.max == affixProto.min) return affixProto.min;

    uint256 range = affixProto.max - affixProto.min;
    uint256 result = randomness % range;
    return result + affixProto.min;
  }

  /// @dev Hardcoded ilvl => AffixPartsIds mapping
  function _getAffixPartIds(uint256 ilvl) internal pure returns (AffixPartId[] memory result) {
    if (ilvl == 1) {
      result = new AffixPartId[](1);
      result[0] = AffixPartId.IMPLICIT;
    } else if (ilvl == 2) {
      result = new AffixPartId[](2);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
    } else if (ilvl >= 3) {
      result = new AffixPartId[](3);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
    } else {
      revert LibPickAffixes__InvalidIlvl(ilvl);
    }
  }

  function _isIn(
    uint256 entity, uint256[] memory array
  ) private pure returns (bool) {
    for (uint256 i; i < array.length; i++) {
      if (array[i] == entity) return true;
    }
    return false;
  }

  function _concatArrays(
    uint256[] memory array1,
    uint256[] memory array2
  ) private pure returns (uint256[] memory result) {
    if (array1.length == 0) return array2;
    if (array2.length == 0) return array1;

    uint256 totalIndex;
    result = new uint256[](array1.length + array2.length);
    for (uint256 i; i < array1.length; i++) {
      result[totalIndex] = array1[i];
      totalIndex++;
    }
    for (uint256 i; i < array2.length; i++) {
      result[totalIndex] = array2[i];
      totalIndex++;
    }
    return result;
  }
}