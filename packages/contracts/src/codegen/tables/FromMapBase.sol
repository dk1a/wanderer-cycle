// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

// Import schema type
import { SchemaType } from "@latticexyz/schema-type/src/solidity/SchemaType.sol";

// Import store internals
import { IStore } from "@latticexyz/store/src/IStore.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { StoreCore } from "@latticexyz/store/src/StoreCore.sol";
import { Bytes } from "@latticexyz/store/src/Bytes.sol";
import { Memory } from "@latticexyz/store/src/Memory.sol";
import { SliceLib } from "@latticexyz/store/src/Slice.sol";
import { EncodeArray } from "@latticexyz/store/src/tightcoder/EncodeArray.sol";
import { Schema, SchemaLib } from "@latticexyz/store/src/Schema.sol";
import { PackedCounter, PackedCounterLib } from "@latticexyz/store/src/PackedCounter.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("FromMapBase")));
bytes32 constant FromMapBaseTableId = _tableId;

library FromMapBase {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.UINT256;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.UINT256;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](1);
    _fieldNames[0] = "value";
    return ("FromMapBase", _fieldNames);
  }

  /** Register the table's schema */
  function registerSchema() internal {
    StoreSwitch.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Register the table's schema (using the specified store) */
  function registerSchema(IStore _store) internal {
    _store.registerSchema(_tableId, getSchema(), getKeySchema());
  }

  /** Set the table's metadata */
  function setMetadata() internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    StoreSwitch.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Set the table's metadata (using the specified store) */
  function setMetadata(IStore _store) internal {
    (string memory _tableName, string[] memory _fieldNames) = getMetadata();
    _store.setMetadata(_tableId, _tableName, _fieldNames);
  }

  /** Get value */
  function get(uint256 entity) internal view returns (uint256 value) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 0);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Get value (using the specified store) */
  function get(IStore _store, uint256 entity) internal view returns (uint256 value) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 0);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Set value */
  function set(uint256 entity, uint256 value) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 0, abi.encodePacked((value)));
  }

  /** Set value (using the specified store) */
  function set(IStore _store, uint256 entity, uint256 value) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 0, abi.encodePacked((value)));
  }

  /** Tightly pack full data using this table's schema */
  function encode(uint256 value) internal view returns (bytes memory) {
    return abi.encodePacked(value);
  }

  /* Delete all data for given keys */
  function deleteRecord(uint256 entity) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.deleteRecord(_tableId, _primaryKeys);
  }

  /* Delete all data for given keys (using the specified store) */
  function deleteRecord(IStore _store, uint256 entity) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.deleteRecord(_tableId, _primaryKeys);
  }
}
