// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { EncodedLengths } from "@latticexyz/store/src/EncodedLengths.sol";
import { getKeysWithValue } from "@latticexyz/world-modules/src/modules/keyswithvalue/getKeysWithValue.sol";

import { AffixPartId } from "../../codegen/common.sol";
import { AffixAvailabilityTargetId } from "./types.sol";
import { Affix, AffixData } from "./codegen/tables/Affix.sol";
import { AffixPrototypeAvailable } from "./codegen/tables/AffixPrototypeAvailable.sol";
import { AffixPrototype, AffixPrototypeData } from "./codegen/tables/AffixPrototype.sol";
import { Idx_AffixPrototype_ExclusiveGroup } from "./codegen/idxs/Idx_AffixPrototype_ExclusiveGroup.sol";
import { UniqueIdx_AffixPrototype_AffixTierName } from "./codegen/idxs/UniqueIdx_AffixPrototype_AffixTierName.sol";
import { LibArray } from "../../utils/LibArray.sol";

/// @title Randomly pick affixes.
library LibPickAffix {
  error LibPickAffix_NoAvailableAffix(
    AffixPartId affixPartId,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl
  );
  error LibPickAffix_InvalidTierName(uint32 affixTier, string name);
  error LibPickAffix_InvalidMinMax(uint32 min, uint32 max);
  error LibPickAffix_MalformedInputManualPick(uint256 namesLength, uint256 affixTiersLength);

  function pickAffixes(
    AffixPartId[] memory affixPartIds,
    bytes32[] memory excludeProtoEntities,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    uint32 ilvl,
    uint256 randomness
  )
    internal
    view
    returns (bytes32[] memory statmodEntities, bytes32[] memory affixProtoEntities, uint32[] memory affixValues)
  {
    statmodEntities = new bytes32[](affixPartIds.length);
    affixProtoEntities = new bytes32[](affixPartIds.length);
    affixValues = new uint32[](affixPartIds.length);

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

      // set the corresponding statmod
      statmodEntities[i] = AffixPrototype.getStatmodEntity(affixProtoEntity);

      // pick its value
      affixProtoEntities[i] = affixProtoEntity;
      affixValues[i] = _pickAffixValue(
        AffixPrototype.getMin(affixProtoEntity),
        AffixPrototype.getMax(affixProtoEntity),
        randomness
      );

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

  function manuallyPickAffixesMax(
    string[] memory names,
    uint32[] memory affixTiers
  )
    internal
    view
    returns (bytes32[] memory statmodEntities, bytes32[] memory affixProtoEntities, uint32[] memory affixValues)
  {
    if (names.length != affixTiers.length) {
      revert LibPickAffix_MalformedInputManualPick(names.length, affixTiers.length);
    }
    uint256 len = names.length;
    statmodEntities = new bytes32[](len);
    affixProtoEntities = new bytes32[](len);
    affixValues = new uint32[](len);

    for (uint32 i; i < len; i++) {
      affixProtoEntities[i] = UniqueIdx_AffixPrototype_AffixTierName.get(affixTiers[i], names[i]);
      if (affixProtoEntities[i] == bytes32(0)) {
        revert LibPickAffix_InvalidTierName(affixTiers[i], names[i]);
      }

      statmodEntities[i] = AffixPrototype.getStatmodEntity(affixProtoEntities[i]);
      affixValues[i] = AffixPrototype.getMax(affixProtoEntities[i]);
    }
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
      revert LibPickAffix_NoAvailableAffix(affixPartId, affixAvailabilityTargetId, ilvl);

    uint256 index = randomness % availableEntities.length;
    return availableEntities[index];
  }

  /// @dev Queries the default availability and removes `excludeProtoEntities` from it.
  function _getAvailableEntities(
    uint32 ilvl,
    AffixPartId affixPartId,
    AffixAvailabilityTargetId affixAvailabilityTargetId,
    bytes32[] memory excludeProtoEntities
  ) private view returns (bytes32[] memory availableEntities) {
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

  /// @dev Randomly pick an affix value.
  function _pickAffixValue(uint32 min, uint32 max, uint256 randomness) internal pure returns (uint32) {
    randomness = uint256(keccak256(abi.encode(keccak256("_pickAffixValue"), randomness)));

    if (max < min) revert LibPickAffix_InvalidMinMax(min, max);

    uint32 range = max - min + 1;
    uint32 result = uint32(randomness % range);
    return result + min;
  }
}
