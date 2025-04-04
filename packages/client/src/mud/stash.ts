import isEqual from "react-fast-compare";
import { Table } from "@latticexyz/config";
import {
  createStash,
  getRecord,
  GetRecordArgs,
  GetRecordResult,
  Key,
  State,
  TableRecord,
} from "@latticexyz/stash/internal";
import { useStash } from "@latticexyz/stash/react";
import mudConfig from "contracts/mud.config";

export const stash = createStash(mudConfig);

export type StateLocal = State<typeof mudConfig>;

export const mudTables = mudConfig.tables;

/**
 * Throws an error if no value exists, so it can't return `undefined`
 * Otherwise identical to `getRecord`
 */
export function getRecordStrict<
  const table extends Table,
  defaultValue extends
    | Omit<TableRecord<table>, keyof Key<table>>
    | undefined = undefined,
>(
  args: GetRecordArgs<table, defaultValue>,
): GetRecordResult<table, defaultValue> & {} {
  const result = getRecord(args);
  if (result === undefined) {
    throw new Error(
      `No record for table ${args.table.label} on key ${JSON.stringify(args.key)}`,
    );
  }
  return result;
}

export function useStashCustom<T>(
  /**
   * Selector to pick values from state.
   * Be aware of the stability of both the `selector` and the return value, otherwise you may end up with unnecessary re-renders.
   */
  selector: (state: State<typeof mudConfig>) => T,
): T {
  return useStash(stash, selector, { isEqual });
}
