// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { LibArray } from "../libraries/LibArray.sol";

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

/// @title Randomly pick affixes.
library LibPickAffixes {
  error LibPickAffixes__NoAvailableAffix(uint256 ilvl, AffixPartId affixPartId, uint256 protoEntity);
  error LibPickAffixes__InvalidMinMax();
  error LibPickAffixes__InvalidIlvl(uint256 ilvl);

  struct Comps {
    AffixPrototypeComponent affixProto;
    AffixAvailabilityComponent availability;
    AffixPrototypeGroupComponent group;
  }

  function pickAffixes(
    IUint256Component components,
    AffixPartId[] memory affixPartIds,
    uint256[] memory excludeAffixes,
    uint256 targetEntity,
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
        targetEntity,
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
        excludeAffixes = LibArray.concat(excludeAffixes, newExcludeAffixes);
      }
    }
  }

  /// @dev Randomly pick an affix entity from the available set.
  function _pickAffixProtoEntity(
    Comps memory comps,
    uint256 ilvl,
    AffixPartId affixPartId,
    uint256 targetEntity,
    uint256[] memory excludeAffixes,
    uint256 randomness
  ) internal view returns (uint256) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickAffixEntity"), randomness)));

    // TODO this can be significantly optimized if you need it
    uint256 availabilityEntity = getAffixAvailabilityEntity(ilvl, affixPartId, targetEntity);
    uint256[] memory entities = _getAvailableEntities(comps, availabilityEntity, excludeAffixes);
    if (entities.length == 0) revert LibPickAffixes__NoAvailableAffix(ilvl, affixPartId, targetEntity);

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
      if (LibArray.isIn(availableEntities[i], excludeEntities)) {
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
}