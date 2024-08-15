// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

type MapType is bytes32;

library MapTypes {
  MapType constant BASIC = MapType.wrap("Basic");
  MapType constant RANDOM = MapType.wrap("Random");
  MapType constant CYCLE_BOSS = MapType.wrap("Cycle Boss");
}
