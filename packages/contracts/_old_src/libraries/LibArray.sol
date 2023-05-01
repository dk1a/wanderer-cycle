// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

library LibArray {
  function isIn(uint256 entity, uint256[] memory array) internal pure returns (bool) {
    for (uint256 i; i < array.length; i++) {
      if (array[i] == entity) return true;
    }
    return false;
  }

  function concat(uint256[] memory array1, uint256[] memory array2) internal pure returns (uint256[] memory result) {
    if (array1.length == 0) return array2;
    if (array2.length == 0) return array1;

    uint256 totalIndex;
    result = new uint256[](array1.length + array2.length);
    for (uint256 i; i < array1.length; i++) {
      result[totalIndex] = array1[i];
      totalIndex++;
    }
    for (uint256 i; i < array2.length; i++) {
      result[totalIndex] = array2[i];
      totalIndex++;
    }
    return result;
  }
}
