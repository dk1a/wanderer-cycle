// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

/* Autogenerated file. Do not edit manually. */

// Import store internals
import { ResourceId } from "@latticexyz/store/src/ResourceId.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";

// Import idx internals
import { Uint8Map, Uint8MapLib } from "@dk1a/mud-table-idxs/src/Uint8Map.sol";
import { hashIndexes, hashValues } from "@dk1a/mud-table-idxs/src/utils.sol";

import { IIdxErrors } from "@dk1a/mud-table-idxs/src/IIdxErrors.sol";

import { registerUniqueIdx } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/registerUniqueIdx.sol";
import { UniqueIdx } from "@dk1a/mud-table-idxs/src/namespaces/uniqueIdx/codegen/tables/UniqueIdx.sol";

library UniqueIdx_AffixPrototype_AffixTierName {
  // Hex below is the result of `WorldResourceIdLib.encode({ namespace: "affix", name: "AffixPrototype", typeId: RESOURCE_TABLE });`
  ResourceId constant _tableId = ResourceId.wrap(0x74626166666978000000000000000000416666697850726f746f747970650000);

  uint256 constant _keyNumber = 0;
  uint256 constant _fieldNumber = 2;

  Uint8Map constant _keyIndexes = Uint8Map.wrap(0x0000000000000000000000000000000000000000000000000000000000000000);
  Uint8Map constant _fieldIndexes = Uint8Map.wrap(0x0202050000000000000000000000000000000000000000000000000000000000);

  bytes32 constant _indexesHash = 0x680e62f238ddf977bbe9345221296adb9cb346acd86697e29f1e11d4c5a5d2f7;

  function valuesHash(uint32 affixTier, string memory name) internal pure returns (bytes32) {
    bytes32[] memory _partialKeyTuple = new bytes32[](_keyNumber);

    bytes[] memory _partialValues = new bytes[](_fieldNumber);

    _partialValues[0] = abi.encodePacked((affixTier));

    _partialValues[1] = bytes((name));

    return hashValues(_partialKeyTuple, _partialValues);
  }

  // Should be called once in e.g. PostDeploy
  function register() internal {
    registerUniqueIdx(_tableId, _keyIndexes, _fieldIndexes);
  }

  function has(uint32 affixTier, string memory name) internal view returns (bool) {
    bytes32 _valuesHash = valuesHash(affixTier, name);

    return UniqueIdx.length(_tableId, _indexesHash, _valuesHash) > 0;
  }

  function getKeyTuple(uint32 affixTier, string memory name) internal view returns (bytes32[] memory _keyTuple) {
    bytes32 _valuesHash = valuesHash(affixTier, name);

    _keyTuple = UniqueIdx.get(_tableId, _indexesHash, _valuesHash);

    if (_keyTuple.length == 0) {
      revert IIdxErrors.UniqueIdx_InvalidGet({
        tableId: _tableId,
        libraryName: "UniqueIdx_AffixPrototype_AffixTierName",
        valuesBlob: abi.encodePacked(affixTier, name),
        indexesHash: _indexesHash,
        valuesHash: _valuesHash
      });
    }
  }

  function get(uint32 affixTier, string memory name) internal view returns (bytes32 entity) {
    bytes32[] memory _keyTuple = getKeyTuple(affixTier, name);

    entity = _keyTuple[0];
  }

  /**
   * @notice Decode keys from a bytes32 array using the source table's field layout.
   */
  function decodeKeyTuple(bytes32[] memory _keyTuple) internal pure returns (bytes32 entity) {
    entity = _keyTuple[0];
  }
}
