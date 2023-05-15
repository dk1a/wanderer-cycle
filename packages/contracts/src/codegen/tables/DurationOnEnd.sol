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

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("DurationOnEnd")));
bytes32 constant DurationOnEndTableId = _tableId;

struct DurationOnEndData {
  bytes16 namespace;
  bytes16 file;
  bytes funcSelectorAndArgs;
}

library DurationOnEnd {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.BYTES16;
    _schema[1] = SchemaType.BYTES16;
    _schema[2] = SchemaType.BYTES;

    return SchemaLib.encode(_schema);
  }

  function getKeySchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](1);
    _schema[0] = SchemaType.UINT256;

    return SchemaLib.encode(_schema);
  }

  /** Get the table's metadata */
  function getMetadata() internal pure returns (string memory, string[] memory) {
    string[] memory _fieldNames = new string[](3);
    _fieldNames[0] = "namespace";
    _fieldNames[1] = "file";
    _fieldNames[2] = "funcSelectorAndArgs";
    return ("DurationOnEnd", _fieldNames);
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

  /** Get namespace */
  function getNamespace(uint256 entity) internal view returns (bytes16 namespace) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 0);
    return (Bytes.slice16(_blob, 0));
  }

  /** Get namespace (using the specified store) */
  function getNamespace(IStore _store, uint256 entity) internal view returns (bytes16 namespace) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 0);
    return (Bytes.slice16(_blob, 0));
  }

  /** Set namespace */
  function setNamespace(uint256 entity, bytes16 namespace) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 0, abi.encodePacked((namespace)));
  }

  /** Set namespace (using the specified store) */
  function setNamespace(IStore _store, uint256 entity, bytes16 namespace) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 0, abi.encodePacked((namespace)));
  }

  /** Get file */
  function getFile(uint256 entity) internal view returns (bytes16 file) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 1);
    return (Bytes.slice16(_blob, 0));
  }

  /** Get file (using the specified store) */
  function getFile(IStore _store, uint256 entity) internal view returns (bytes16 file) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 1);
    return (Bytes.slice16(_blob, 0));
  }

  /** Set file */
  function setFile(uint256 entity, bytes16 file) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 1, abi.encodePacked((file)));
  }

  /** Set file (using the specified store) */
  function setFile(IStore _store, uint256 entity, bytes16 file) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 1, abi.encodePacked((file)));
  }

  /** Get funcSelectorAndArgs */
  function getFuncSelectorAndArgs(uint256 entity) internal view returns (bytes memory funcSelectorAndArgs) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 2);
    return (bytes(_blob));
  }

  /** Get funcSelectorAndArgs (using the specified store) */
  function getFuncSelectorAndArgs(
    IStore _store,
    uint256 entity
  ) internal view returns (bytes memory funcSelectorAndArgs) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 2);
    return (bytes(_blob));
  }

  /** Set funcSelectorAndArgs */
  function setFuncSelectorAndArgs(uint256 entity, bytes memory funcSelectorAndArgs) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 2, bytes((funcSelectorAndArgs)));
  }

  /** Set funcSelectorAndArgs (using the specified store) */
  function setFuncSelectorAndArgs(IStore _store, uint256 entity, bytes memory funcSelectorAndArgs) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 2, bytes((funcSelectorAndArgs)));
  }

  /** Push a slice to funcSelectorAndArgs */
  function pushFuncSelectorAndArgs(uint256 entity, bytes memory _slice) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.pushToField(_tableId, _primaryKeys, 2, bytes((_slice)));
  }

  /** Push a slice to funcSelectorAndArgs (using the specified store) */
  function pushFuncSelectorAndArgs(IStore _store, uint256 entity, bytes memory _slice) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.pushToField(_tableId, _primaryKeys, 2, bytes((_slice)));
  }

  /** Update a slice of funcSelectorAndArgs at `_index` */
  function updateFuncSelectorAndArgs(uint256 entity, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.updateInField(_tableId, _primaryKeys, 2, _index * 1, bytes((_slice)));
  }

  /** Update a slice of funcSelectorAndArgs (using the specified store) at `_index` */
  function updateFuncSelectorAndArgs(IStore _store, uint256 entity, uint256 _index, bytes memory _slice) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.updateInField(_tableId, _primaryKeys, 2, _index * 1, bytes((_slice)));
  }

  /** Get the full data */
  function get(uint256 entity) internal view returns (DurationOnEndData memory _table) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _primaryKeys, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, uint256 entity) internal view returns (DurationOnEndData memory _table) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getRecord(_tableId, _primaryKeys, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(uint256 entity, bytes16 namespace, bytes16 file, bytes memory funcSelectorAndArgs) internal {
    bytes memory _data = encode(namespace, file, funcSelectorAndArgs);

    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setRecord(_tableId, _primaryKeys, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(
    IStore _store,
    uint256 entity,
    bytes16 namespace,
    bytes16 file,
    bytes memory funcSelectorAndArgs
  ) internal {
    bytes memory _data = encode(namespace, file, funcSelectorAndArgs);

    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setRecord(_tableId, _primaryKeys, _data);
  }

  /** Set the full data using the data struct */
  function set(uint256 entity, DurationOnEndData memory _table) internal {
    set(entity, _table.namespace, _table.file, _table.funcSelectorAndArgs);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, uint256 entity, DurationOnEndData memory _table) internal {
    set(_store, entity, _table.namespace, _table.file, _table.funcSelectorAndArgs);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal view returns (DurationOnEndData memory _table) {
    // 32 is the total byte length of static data
    PackedCounter _encodedLengths = PackedCounter.wrap(Bytes.slice32(_blob, 32));

    _table.namespace = (Bytes.slice16(_blob, 0));

    _table.file = (Bytes.slice16(_blob, 16));

    // Store trims the blob if dynamic fields are all empty
    if (_blob.length > 32) {
      uint256 _start;
      // skip static data length + dynamic lengths word
      uint256 _end = 64;

      _start = _end;
      _end += _encodedLengths.atIndex(0);
      _table.funcSelectorAndArgs = (bytes(SliceLib.getSubslice(_blob, _start, _end).toBytes()));
    }
  }

  /** Tightly pack full data using this table's schema */
  function encode(
    bytes16 namespace,
    bytes16 file,
    bytes memory funcSelectorAndArgs
  ) internal view returns (bytes memory) {
    uint16[] memory _counters = new uint16[](1);
    _counters[0] = uint16(bytes(funcSelectorAndArgs).length);
    PackedCounter _encodedLengths = PackedCounterLib.pack(_counters);

    return abi.encodePacked(namespace, file, _encodedLengths.unwrap(), bytes((funcSelectorAndArgs)));
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