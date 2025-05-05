import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";

export function getBossesDefeated(
  state: StateLocal,
  entity: Hex | undefined,
): readonly Hex[] {
  if (entity === undefined) return [];
  const mapEntities = getRecord({
    state,
    table: mudTables.cycle__BossesDefeated,
    key: { entity },
  })?.value;
  return mapEntities ?? [];
}
