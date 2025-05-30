// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { System } from "@latticexyz/world/src/System.sol";

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { Wanderer } from "../wanderer/codegen/tables/Wanderer.sol";
import { LootAffixes } from "../loot/codegen/tables/LootAffixes.sol";

import { LibUriWanderer } from "./LibUriWanderer.sol";
import { LibUriLoot } from "./LibUriLoot.sol";
import { LibUriMisc } from "./LibUriMisc.sol";

contract UriSystem is System {
  function entityURI(bytes32 entity) public view returns (string memory) {
    string memory json;
    if (Wanderer.get(entity)) {
      json = LibUriWanderer.json(entity);
    } else if (LootAffixes.length(entity) > 0) {
      json = LibUriLoot.json(entity);
    } else {
      json = LibUriMisc.json(entity);
    }
    return string.concat("data:application/json;base64,", json);
  }
}
