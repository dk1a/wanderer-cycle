// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";
import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import { Affix, AffixData } from "./codegen/tables/Affix.sol";
import { AffixPrototypeAvailable } from "./codegen/tables/AffixPrototypeAvailable.sol";
import { AffixPrototype, AffixPrototypeData } from "./codegen/tables/AffixPrototype.sol";
import { Idx_AffixPrototype_ExclusiveGroup } from "./codegen/idxs/Idx_AffixPrototype_ExclusiveGroup.sol";
import { UniqueIdx_AffixPrototype_AffixTierName } from "./codegen/idxs/UniqueIdx_AffixPrototype_AffixTierName.sol";

import { entitySystem } from "../evefrontier/codegen/systems/EntitySystemLib.sol";
import { LibSOFClass } from "../common/LibSOFClass.sol";
import { LibArray } from "../../utils/LibArray.sol";
import { AffixPartId } from "../../codegen/common.sol";
import { AffixAvailabilityTargetId } from "./types.sol";

/**
 * @notice Instantiates affixes.
 * @dev Callable by anyone - they're just records that other systems can reference.
 */
contract AffixSystem is System {
  error AffixSystem_NoAvailableAffix(
    AffixPartId affixPartId,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl
  );
  error AffixSystem_InvalidTierName(uint32 affixTier, string name);
  error AffixSystem_InvalidMinMax(uint32 min, uint32 max);
  error AffixSystem_MalformedInputManualPick(uint256 affixPartIdsLength, uint256 namesLength, uint256 affixTiersLength);

  function instantiateRandomAffixes(
    AffixPartId[] memory affixPartIds,
    bytes32[] memory excludeProtoEntities,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl,
    uint256 randomness
  ) public returns (bytes32[] memory affixEntities) {
    affixEntities = new bytes32[](affixPartIds.length);

    for (uint256 i; i < affixPartIds.length; i++) {
      randomness = uint256(keccak256(abi.encode(i, randomness)));
      // pick affix proto entity
      bytes32 affixProtoEntity = _pickAffixProtoEntity(
        ilvl,
        affixPartIds[i],
        affixAvailabilityTargetId,
        excludeProtoEntities,
        randomness
      );

      // pick its value
      uint32 affixValue = _pickAffixValue(
        AffixPrototype.getMin(affixProtoEntity),
        AffixPrototype.getMax(affixProtoEntity),
        randomness
      );

      // instantiate the new affix
      affixEntities[i] = _instantiateAffix(affixProtoEntity, affixPartIds[i], affixValue);

      if (i != affixPartIds.length - 1) {
        // exclude the other affix prototypes of the same exclusive group (skip for the last cycle)
        bytes32 exclusiveGroup = AffixPrototype.getExclusiveGroup(affixProtoEntity);
        excludeProtoEntities = LibArray.concat(excludeProtoEntities, _getWithExclusiveGroup(exclusiveGroup));
      }
    }
  }

  // TODO build a simple getter into idxgen maybe
  function _getWithExclusiveGroup(bytes32 exclusiveGroup) internal view returns (bytes32[] memory affixProtoEntities) {
    uint256 length = Idx_AffixPrototype_ExclusiveGroup.length(exclusiveGroup);
    affixProtoEntities = new bytes32[](length);
    for (uint256 i; i < length; i++) {
      affixProtoEntities[i] = Idx_AffixPrototype_ExclusiveGroup.get(exclusiveGroup, i);
    }
    return affixProtoEntities;
  }

  function instantiateManualAffixesMax(
    AffixPartId[] memory affixPartIds,
    string[] memory names,
    uint32[] memory affixTiers
  ) public returns (bytes32[] memory affixEntities) {
    if (affixPartIds.length != names.length || names.length != affixTiers.length) {
      revert AffixSystem_MalformedInputManualPick(affixPartIds.length, names.length, affixTiers.length);
    }
    uint256 len = names.length;
    affixEntities = new bytes32[](len);

    for (uint32 i; i < len; i++) {
      bytes32 affixProtoEntity = UniqueIdx_AffixPrototype_AffixTierName.get(affixTiers[i], names[i]);
      if (affixProtoEntity == bytes32(0)) {
        revert AffixSystem_InvalidTierName(affixTiers[i], names[i]);
      }

      uint32 affixValue = AffixPrototype.getMax(affixProtoEntity);

      // instantiate the new affix
      affixEntities[i] = _instantiateAffix(affixProtoEntity, affixPartIds[i], affixValue);
    }
  }

  /// @dev Instantiate an affix entity with the given prototype, part id and value.
  function _instantiateAffix(
    bytes32 affixProtoEntity,
    AffixPartId affixPartId,
    uint32 affixValue
  ) internal returns (bytes32 affixEntity) {
    // instantiate the affix entity (renounce the role, affixes are controlled only by the affix system via scope)
    affixEntity = bytes32(entitySystem.instantiate(uint256(affixProtoEntity), address(this)));
    LibSOFClass.scopedRenounceRole(affixEntity);

    // set the affix data
    Affix.set(affixEntity, affixProtoEntity, affixPartId, affixValue);

    return affixEntity;
  }

  /// @dev Randomly pick an affix entity from the available set.
  function _pickAffixProtoEntity(
    uint32 ilvl,
    AffixPartId affixPartId,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    bytes32[] memory excludeProtoEntities,
    uint256 randomness
  ) internal view returns (bytes32) {
    randomness = uint256(keccak256(abi.encode(keccak256("pickAffixEntity"), randomness)));

    // TODO this can be significantly optimized if you need it
    bytes32[] memory availableEntities = _getAvailableEntities(
      ilvl,
      affixPartId,
      affixAvailabilityTargetId,
      excludeProtoEntities
    );
    if (availableEntities.length == 0)
      revert AffixSystem_NoAvailableAffix(affixPartId, affixAvailabilityTargetId, ilvl);

    uint256 index = randomness % availableEntities.length;
    return availableEntities[index];
  }

  /// @dev Queries the default availability and removes `excludeProtoEntities` from it.
  function _getAvailableEntities(
    uint32 ilvl,
    AffixPartId affixPartId,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    bytes32[] memory excludeProtoEntities
  ) internal view returns (bytes32[] memory availableEntities) {
    // get default availability
    availableEntities = AffixPrototypeAvailable.get(affixPartId, affixAvailabilityTargetId, ilvl);

    for (uint256 i; i < availableEntities.length; i++) {
      // exclude the specified entities
      if (LibArray.isIn(availableEntities[i], excludeProtoEntities)) {
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
}

/// @dev Randomly pick an affix value.
function _pickAffixValue(uint32 min, uint32 max, uint256 randomness) pure returns (uint32) {
  randomness = uint256(keccak256(abi.encode(keccak256("_pickAffixValue"), randomness)));

  if (max < min) revert AffixSystem.AffixSystem_InvalidMinMax(min, max);

  uint32 range = max - min + 1;
  uint32 result = uint32(randomness % range);
  return result + min;
}
