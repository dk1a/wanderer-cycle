import { Hex } from "viem";
import { Table } from "@latticexyz/config";
import { getRecord, GetRecordArgs } from "@latticexyz/stash/internal";
import { AbiTypeScope, resolveSchema } from "@latticexyz/store/internal";
import { getRecordStrict, StateLocal } from "../stash";
import { formatZeroTerminatedString } from "./format";

export interface ParsedDuration {
  timeId: string;
  timeValue: number;
}

interface DurationTable extends Table {
  readonly schema: Table["schema"] &
    resolveSchema<
      {
        timeId: "bytes32";
        timeValue: "uint256";
      },
      AbiTypeScope
    >;
}

export function parseDuration(duration: {
  timeId: Hex;
  timeValue: bigint;
}): ParsedDuration {
  if (duration.timeValue > Number.MAX_VALUE) {
    console.error("Duration value exceeds max safe integer", duration);
  }
  return {
    timeId: formatZeroTerminatedString(duration.timeId),
    timeValue: Number(duration.timeValue),
  };
}

export function getDurationRecord<const table extends DurationTable>(
  args: GetRecordArgs<table> & { state: StateLocal },
): ParsedDuration | undefined {
  const duration = getRecord(args);
  if (!duration) return undefined;
  return parseDuration(duration);
}

export function getDurationRecordStrict<const table extends DurationTable>(
  args: GetRecordArgs<table> & { state: StateLocal },
): ParsedDuration {
  const duration = getRecordStrict(args);
  return parseDuration(duration);
}
