// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

function mapLevelToAffixTier(uint32 mapLevel) pure returns (uint32 affixTier) {
  affixTier = (mapLevel - 1) / 4 + 1;
}
