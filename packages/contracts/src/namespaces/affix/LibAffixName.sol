// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AffixNaming } from "./codegen/tables/AffixNaming.sol";
import { AffixNamingTargeted } from "./codegen/tables/AffixNamingTargeted.sol";
import { AffixAvailabilityTargetId } from "./types.sol";
import { AffixPartId } from "../../codegen/common.sol";

library LibAffixName {
  function getAffixNaming(
    bytes32 affixPrototypeEntity,
    AffixPartId partId,
    AffixAvailabilityTargetId targetId
  ) internal view returns (string memory affixNaming) {
    affixNaming = AffixNamingTargeted.get(affixPrototypeEntity, partId, targetId);
    if (bytes(affixNaming).length == 0) {
      affixNaming = AffixNaming.get(affixPrototypeEntity, partId);
    }
  }

  function getPartIdName(AffixPartId partId) internal pure returns (string memory) {
    if (partId == AffixPartId.PREFIX) {
      return "prefix";
    } else if (partId == AffixPartId.IMPLICIT) {
      return "implicit";
    } else if (partId == AffixPartId.SUFFIX) {
      return "suffix";
    } else {
      return "unknown";
    }
  }
}
