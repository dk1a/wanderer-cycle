// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { LibTypes } from "solecs/LibTypes.sol";
import { BareComponent } from "solecs/BareComponent.sol";

import { PS_L } from "../charstat/ExperienceComponent.sol";

uint256 constant ID = uint256(keccak256("component.CycleCombatRewardRequest"));

struct CycleCombatRewardRequestData {
  uint256 mapEntity;
  uint32 connection;
  uint32 fortune;
  uint32[PS_L] winnerPstats;
  uint32[PS_L] loserPstats;
}

/// @dev requestId => cycleEntity
/// Use `getEntitiesWithValue` to get cycleEntity's unfulfilled reward requests
contract CycleCombatRewardRequestComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](3 + 2 * PS_L);
    values = new LibTypes.SchemaValue[](3 + 2 * PS_L);

    keys[0] = "mapEntity";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "connection";
    values[1] = LibTypes.SchemaValue.UINT32;

    keys[2] = "fortune";
    values[2] = LibTypes.SchemaValue.UINT32;

    keys[3] = "winner_strength";
    values[3] = LibTypes.SchemaValue.UINT32;

    keys[4] = "winner_arcana";
    values[4] = LibTypes.SchemaValue.UINT32;

    keys[5] = "winner_dexterity";
    values[5] = LibTypes.SchemaValue.UINT32;

    keys[6] = "loser_strength";
    values[6] = LibTypes.SchemaValue.UINT32;

    keys[7] = "loser_arcana";
    values[7] = LibTypes.SchemaValue.UINT32;

    keys[8] = "loser_dexterity";
    values[8] = LibTypes.SchemaValue.UINT32;
  }

  function getValue(uint256 entity) public view returns (CycleCombatRewardRequestData memory result) {
    return abi.decode(getRawValue(entity), (CycleCombatRewardRequestData));
  }

  function set(uint256 entity, CycleCombatRewardRequestData memory data) public {
    set(entity, abi.encode(data));
  }
}
