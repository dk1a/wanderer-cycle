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

// Import user types
import { AffixPartId } from "./../Types.sol";

bytes32 constant _tableId = bytes32(abi.encodePacked(bytes16(""), bytes16("Affix")));
bytes32 constant AffixTableId = _tableId;

struct AffixData {
  AffixPartId partId;
  uint256 protoEntity;
  uint32 value;
}

library Affix {
  /** Get the table's schema */
  function getSchema() internal pure returns (Schema) {
    SchemaType[] memory _schema = new SchemaType[](3);
    _schema[0] = SchemaType.UINT8;
    _schema[1] = SchemaType.UINT256;
    _schema[2] = SchemaType.UINT32;

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
    _fieldNames[0] = "partId";
    _fieldNames[1] = "protoEntity";
    _fieldNames[2] = "value";
    return ("Affix", _fieldNames);
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

  /** Get partId */
  function getPartId(uint256 entity) internal view returns (AffixPartId partId) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 0);
    return AffixPartId(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Get partId (using the specified store) */
  function getPartId(IStore _store, uint256 entity) internal view returns (AffixPartId partId) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 0);
    return AffixPartId(uint8(Bytes.slice1(_blob, 0)));
  }

  /** Set partId */
  function setPartId(uint256 entity, AffixPartId partId) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 0, abi.encodePacked(uint8(partId)));
  }

  /** Set partId (using the specified store) */
  function setPartId(IStore _store, uint256 entity, AffixPartId partId) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 0, abi.encodePacked(uint8(partId)));
  }

  /** Get protoEntity */
  function getProtoEntity(uint256 entity) internal view returns (uint256 protoEntity) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 1);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Get protoEntity (using the specified store) */
  function getProtoEntity(IStore _store, uint256 entity) internal view returns (uint256 protoEntity) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 1);
    return (uint256(Bytes.slice32(_blob, 0)));
  }

  /** Set protoEntity */
  function setProtoEntity(uint256 entity, uint256 protoEntity) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 1, abi.encodePacked((protoEntity)));
  }

  /** Set protoEntity (using the specified store) */
  function setProtoEntity(IStore _store, uint256 entity, uint256 protoEntity) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 1, abi.encodePacked((protoEntity)));
  }

  /** Get value */
  function getValue(uint256 entity) internal view returns (uint32 value) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getField(_tableId, _primaryKeys, 2);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Get value (using the specified store) */
  function getValue(IStore _store, uint256 entity) internal view returns (uint32 value) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getField(_tableId, _primaryKeys, 2);
    return (uint32(Bytes.slice4(_blob, 0)));
  }

  /** Set value */
  function setValue(uint256 entity, uint32 value) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setField(_tableId, _primaryKeys, 2, abi.encodePacked((value)));
  }

  /** Set value (using the specified store) */
  function setValue(IStore _store, uint256 entity, uint32 value) internal {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setField(_tableId, _primaryKeys, 2, abi.encodePacked((value)));
  }

  /** Get the full data */
  function get(uint256 entity) internal view returns (AffixData memory _table) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = StoreSwitch.getRecord(_tableId, _primaryKeys, getSchema());
    return decode(_blob);
  }

  /** Get the full data (using the specified store) */
  function get(IStore _store, uint256 entity) internal view returns (AffixData memory _table) {
    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    bytes memory _blob = _store.getRecord(_tableId, _primaryKeys, getSchema());
    return decode(_blob);
  }

  /** Set the full data using individual values */
  function set(uint256 entity, AffixPartId partId, uint256 protoEntity, uint32 value) internal {
    bytes memory _data = encode(partId, protoEntity, value);

    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    StoreSwitch.setRecord(_tableId, _primaryKeys, _data);
  }

  /** Set the full data using individual values (using the specified store) */
  function set(IStore _store, uint256 entity, AffixPartId partId, uint256 protoEntity, uint32 value) internal {
    bytes memory _data = encode(partId, protoEntity, value);

    bytes32[] memory _primaryKeys = new bytes32[](1);
    _primaryKeys[0] = bytes32(uint256((entity)));

    _store.setRecord(_tableId, _primaryKeys, _data);
  }

  /** Set the full data using the data struct */
  function set(uint256 entity, AffixData memory _table) internal {
    set(entity, _table.partId, _table.protoEntity, _table.value);
  }

  /** Set the full data using the data struct (using the specified store) */
  function set(IStore _store, uint256 entity, AffixData memory _table) internal {
    set(_store, entity, _table.partId, _table.protoEntity, _table.value);
  }

  /** Decode the tightly packed blob using this table's schema */
  function decode(bytes memory _blob) internal pure returns (AffixData memory _table) {
    _table.partId = AffixPartId(uint8(Bytes.slice1(_blob, 0)));

    _table.protoEntity = (uint256(Bytes.slice32(_blob, 1)));

    _table.value = (uint32(Bytes.slice4(_blob, 33)));
  }

  /** Tightly pack full data using this table's schema */
  function encode(AffixPartId partId, uint256 protoEntity, uint32 value) internal view returns (bytes memory) {
    return abi.encodePacked(partId, protoEntity, value);
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