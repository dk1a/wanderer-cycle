// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { getAddressById } from "solecs/utils.sol";

import { WandererComponent, ID as WandererComponentID } from "../wanderer/WandererComponent.sol";

import { LibUriWanderer } from "./LibUriWanderer.sol";
import { LibUriMisc } from "./LibUriMisc.sol";

library LibUri {
  function tokenURI(IUint256Component components, uint256 tokenId) internal view returns (string memory) {
    string memory json;
    if (WandererComponent(getAddressById(components, WandererComponentID)).has(tokenId)) {
      json = LibUriWanderer.json(components, tokenId);
    } else {
      json = LibUriMisc.json(tokenId);
    }
    return string.concat("data:application/json;base64,", json);
  }
}
