// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { UriUtils as u } from './UriUtils.sol';

library LibUriMisc {
  /**
   * @dev fallback, avoid using it for circulating tokens
   */
  function json(uint256 tokenId) internal pure returns (string memory) {
    string memory name = string.concat("Token ", Strings.toHexString(
      uint128(bytes16(keccak256(abi.encode("Token", tokenId))))
    ));
    string memory output = string.concat(
      u.START,
      '<text', u.ATTRS_HEADER_TYPE, 'y="40">',
        name,
      '</text>',
      u.END
    );

    return Base64.encode(abi.encodePacked(
        '{"name": "', name, '",',
        '"description": "Miscellaneous token, undeserving of specialized metadata",',
        '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'
    ));
  }
}