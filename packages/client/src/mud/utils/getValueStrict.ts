import { Table, TableRecord } from "@latticexyz/store-sync/zustand";
import { StoreState } from "../setup";

/**
 * Throws an error if no value exists
 * Otherwise identical to `state.getValue`
 */
export function getValueStrict<table extends Table>(
  state: StoreState,
  table: table,
  key: TableRecord<table>["key"],
): TableRecord<table>["value"] {
  const value = state.getValue(table, key);
  if (!value)
    throw new Error(
      `No value for table ${table.label} on key ${JSON.stringify(key)}`,
    );
  return value;
}
