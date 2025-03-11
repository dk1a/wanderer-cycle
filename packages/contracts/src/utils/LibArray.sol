// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

library LibArray {
  function isIn(bytes32 entity, bytes32[] memory array) internal pure returns (bool) {
    for (uint256 i; i < array.length; i++) {
      if (array[i] == entity) return true;
    }
    return false;
  }

  function concat(bytes32[] memory array1, bytes32[] memory array2) internal pure returns (bytes32[] memory result) {
    if (array1.length == 0) return array2;
    if (array2.length == 0) return array1;

    uint256 totalIndex;
    result = new bytes32[](array1.length + array2.length);
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
