// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { System } from "@latticexyz/world/src/System.sol";

import { AffixPartId } from "../../codegen/common.sol";
import { AffixAvailabilityTargetId, AffixPart, TargetLabel } from "./types.sol";

library LibAffixParts {
  // explicits + implicits
  function _affixes(
    string memory prefixLabel,
    string memory suffixLabel,
    AffixAvailabilityTargetId[] memory explicits_targetIds,
    TargetLabel[] memory implicits_targetLabels
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](3);
    // prefix
    separateParts[0] = _commonLabel(AffixPartId.PREFIX, explicits_targetIds, prefixLabel);
    // suffix
    separateParts[1] = _commonLabel(AffixPartId.SUFFIX, explicits_targetIds, suffixLabel);
    // implicit
    separateParts[2] = _individualLabels(AffixPartId.IMPLICIT, implicits_targetLabels);

    return _flatten(separateParts);
  }

  // explicits
  function _explicits(
    string memory prefixLabel,
    string memory suffixLabel,
    AffixAvailabilityTargetId[] memory explicits_targetIds
  ) internal pure returns (AffixPart[] memory) {
    AffixPart[][] memory separateParts = new AffixPart[][](2);
    // prefix
    separateParts[0] = _commonLabel(AffixPartId.PREFIX, explicits_targetIds, prefixLabel);
    // suffix
    separateParts[1] = _commonLabel(AffixPartId.SUFFIX, explicits_targetIds, suffixLabel);

    return _flatten(separateParts);
  }

  // implicits
  function _implicits(TargetLabel[] memory implicits_targetLabels) internal pure returns (AffixPart[] memory) {
    return _individualLabels(AffixPartId.IMPLICIT, implicits_targetLabels);
  }

  // nothing
  function _none() internal pure returns (AffixPart[] memory) {
    return new AffixPart[](0);
  }

  // combine several arrays of affix parts into one
  function _flatten(AffixPart[][] memory separateParts) private pure returns (AffixPart[] memory combinedParts) {
    uint256 combinedLen;
    for (uint256 i; i < separateParts.length; i++) {
      combinedLen += separateParts[i].length;
    }

    combinedParts = new AffixPart[](combinedLen);

    uint256 totalIndex;
    for (uint256 i; i < separateParts.length; i++) {
      AffixPart[] memory separatePart = separateParts[i];
      for (uint256 j; j < separatePart.length; j++) {
        combinedParts[totalIndex] = separatePart[j];
        totalIndex++;
      }
    }
    return combinedParts;
  }

  // 1 label for multiple target ids
  function _commonLabel(
    AffixPartId partId,
    AffixAvailabilityTargetId[] memory targetIds,
    string memory label
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](targetIds.length);

    for (uint256 i; i < targetIds.length; i++) {
      affixParts[i] = AffixPart({ partId: partId, affixAvailabilityTargetId: targetIds[i], label: label });
    }
  }

  // 1 label per each target id
  function _individualLabels(
    AffixPartId partId,
    TargetLabel[] memory targetLabels
  ) private pure returns (AffixPart[] memory affixParts) {
    affixParts = new AffixPart[](targetLabels.length);

    for (uint256 i; i < targetLabels.length; i++) {
      affixParts[i] = AffixPart({
        partId: partId,
        affixAvailabilityTargetId: targetLabels[i].affixAvailabilityTargetId,
        label: targetLabels[i].label
      });
    }
  }
}
