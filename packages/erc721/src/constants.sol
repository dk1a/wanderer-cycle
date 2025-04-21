// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { RESOURCE_SYSTEM } from "@latticexyz/world/src/worldResourceTypes.sol";

import { MODULE_NAMESPACE } from "@latticexyz/world-modules/src/modules/erc721-puppet/constants.sol";

ResourceId constant REGISTER_ERC721_SYSTEM_ID = ResourceId.wrap(
  bytes32(abi.encodePacked(RESOURCE_SYSTEM, MODULE_NAMESPACE, bytes16("RegisterERC721Sy")))
);
