import { Hex } from "viem";
import { getRecord } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";

export function getBossesDefeated(
  state: StateLocal,
  entity: Hex,
): readonly Hex[] {
  const mapEntities = getRecord({
    state,
    table: mudTables.cycle__BossesDefeated,
    key: { entity },
  })?.value;
  return mapEntities ?? [];
}
