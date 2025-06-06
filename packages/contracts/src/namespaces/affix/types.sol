// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { AffixPartId } from "../../codegen/common.sol";

type AffixAvailabilityTargetId is bytes32;

struct AffixParts {
  AffixPartGeneral[] general;
  AffixPartTargeted[] targeted;
}

struct AffixPartGeneral {
  AffixPartId partId;
  AffixAvailabilityTargetId[] targetIds;
  string label;
}

struct AffixPartTargeted {
  AffixPartId partId;
  AffixAvailabilityTargetId targetId;
  string label;
}

struct TargetLabel {
  AffixAvailabilityTargetId targetId;
  string label;
}

/// @dev affix value range
struct Range {
  uint32 min;
  uint32 max;
}
