// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { AffixPartId } from "../../codegen/common.sol";
import { AffixAvailabilityTargetId, AffixPartGeneral, AffixPartTargeted, AffixParts, TargetLabel } from "./types.sol";

library LibAffixParts {
  // explicits + implicits
  function _affixes(
    string memory prefixLabel,
    string memory suffixLabel,
    AffixAvailabilityTargetId[] memory explicits_targetIds,
    TargetLabel[] memory implicits_targetLabels
  ) internal pure returns (AffixParts memory parts) {
    parts.general = new AffixPartGeneral[](2);
    parts.targeted = new AffixPartTargeted[](1);
    // prefix
    parts.general[0] = _generalLabel(AffixPartId.PREFIX, explicits_targetIds, prefixLabel);
    // suffix
    parts.general[1] = _generalLabel(AffixPartId.SUFFIX, explicits_targetIds, suffixLabel);
    // implicit
    parts.targeted = _targetedLabels(AffixPartId.IMPLICIT, implicits_targetLabels);
  }

  // explicits
  function _explicits(
    string memory prefixLabel,
    string memory suffixLabel,
    AffixAvailabilityTargetId[] memory explicits_targetIds
  ) internal pure returns (AffixParts memory parts) {
    parts.general = new AffixPartGeneral[](2);
    // prefix
    parts.general[0] = _generalLabel(AffixPartId.PREFIX, explicits_targetIds, prefixLabel);
    // suffix
    parts.general[1] = _generalLabel(AffixPartId.SUFFIX, explicits_targetIds, suffixLabel);
  }

  // implicits
  function _implicits(TargetLabel[] memory implicits_targetLabels) internal pure returns (AffixParts memory parts) {
    parts.targeted = new AffixPartTargeted[](1);
    // implicit
    parts.targeted = _targetedLabels(AffixPartId.IMPLICIT, implicits_targetLabels);
  }

  // nothing
  function _none() internal pure returns (AffixParts memory result) {
    return result;
  }

  // 1 label for multiple target ids
  function _generalLabel(
    AffixPartId partId,
    AffixAvailabilityTargetId[] memory targetIds,
    string memory label
  ) private pure returns (AffixPartGeneral memory) {
    return AffixPartGeneral({ partId: partId, targetIds: targetIds, label: label });
  }

  // 1 label per each target id
  function _targetedLabels(
    AffixPartId partId,
    TargetLabel[] memory targetLabels
  ) private pure returns (AffixPartTargeted[] memory affixParts) {
    affixParts = new AffixPartTargeted[](targetLabels.length);

    for (uint256 i; i < targetLabels.length; i++) {
      affixParts[i] = AffixPartTargeted({
        partId: partId,
        targetId: targetLabels[i].targetId,
        label: targetLabels[i].label
      });
    }
  }
}
