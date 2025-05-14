// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { UriUtils as u } from "./UriUtils.sol";

library LibUriMisc {
  /**
   * @dev fallback, avoid using it for circulating tokens
   */
  function json(bytes32 entity) internal pure returns (string memory) {
    string memory name = string.concat(
      "Token ",
      Strings.toHexString(uint128(bytes16(keccak256(abi.encode("Token", entity)))))
    );
    // prettier-ignore
    string memory output = string.concat(
      u.START,
      '<text', u.ATTRS_HEADER_TYPE, 'y="40">',
        name,
      '</text>',
      u.END
    );

    // prettier-ignore
    return Base64.encode(abi.encodePacked(
      '{"name": "', name, '",',
      '"description": "Miscellaneous token, undeserving of specialized metadata",',
      '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'
    ));
  }
}
