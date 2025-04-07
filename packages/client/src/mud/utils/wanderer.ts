import { Hex } from "viem";
import { getRecords } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";

export function getWandererEntities(state: StateLocal): Hex[] {
  const result = getRecords({
    state,
    table: mudTables.root__Wanderer,
  });
  return Object.values(result).map(({ entity }) => entity);
}
