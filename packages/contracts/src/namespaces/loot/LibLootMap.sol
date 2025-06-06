// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AffixPartId } from "../../codegen/common.sol";
import { MAX_AFFIX_TIER } from "../affix/constants.sol";

library LibLootMap {
  error LibLootMap_InvalidAffixTier();

  /// @dev Hardcoded affixTier => AffixPartsIds mapping
  function getAffixPartIds(uint256 affixTier) internal pure returns (AffixPartId[] memory result) {
    if (affixTier == 0) {
      revert LibLootMap_InvalidAffixTier();
    } else if (affixTier == 1) {
      result = new AffixPartId[](2);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
    } else if (affixTier == 2) {
      result = new AffixPartId[](3);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
    } else if (affixTier == 3) {
      result = new AffixPartId[](4);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
      result[3] = AffixPartId.PREFIX;
    } else if (affixTier <= MAX_AFFIX_TIER) {
      result = new AffixPartId[](5);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
      result[3] = AffixPartId.PREFIX;
      result[4] = AffixPartId.SUFFIX;
    } else {
      revert LibLootMap_InvalidAffixTier();
    }
  }
}
