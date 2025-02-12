// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixPartId } from "../../../codegen/common.sol";

library LibLootMap {
  error LibLootMap__InvalidIlvl();

  /// @dev Hardcoded ilvl => AffixPartsIds mapping
  function getAffixPartIds(uint256 ilvl) internal pure returns (AffixPartId[] memory result) {
    if (ilvl == 0) {
      revert LibLootMap__InvalidIlvl();
    } else if (ilvl <= 4) {
      result = new AffixPartId[](2);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
    } else if (ilvl <= 8) {
      result = new AffixPartId[](3);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
    } else if (ilvl <= 12) {
      result = new AffixPartId[](4);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
      result[3] = AffixPartId.PREFIX;
    } else if (ilvl <= 16) {
      result = new AffixPartId[](5);
      result[0] = AffixPartId.IMPLICIT;
      result[1] = AffixPartId.PREFIX;
      result[2] = AffixPartId.SUFFIX;
      result[3] = AffixPartId.PREFIX;
      result[4] = AffixPartId.SUFFIX;
    } else {
      revert LibLootMap__InvalidIlvl();
    }
  }
}
