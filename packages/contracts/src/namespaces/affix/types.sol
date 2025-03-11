// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import { AffixPartId } from "../../codegen/common.sol";

type AffixAvailabilityTargetId is bytes32;

struct AffixPart {
  AffixPartId partId;
  AffixAvailabilityTargetId affixAvailabilityTargetId;
  string label;
}

struct TargetLabel {
  AffixAvailabilityTargetId affixAvailabilityTargetId;
  string label;
}

/// @dev affix value range
struct Range {
  uint32 min;
  uint32 max;
}
