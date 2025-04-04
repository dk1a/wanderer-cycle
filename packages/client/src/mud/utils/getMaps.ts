import { Hex, toHex } from "viem";
import { getRecords } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";
import { getLoot, LootData } from "./getLoot";

export interface MapData {
  entity: Hex;
  lootData: LootData;
  mapType: Hex;
}

export function getMaps(
  state: StateLocal,
  mapType: Hex | undefined,
): MapData[] {
  let maps = Object.values(
    getRecords({ state, table: mudTables.root__MapTypeComponent }),
  );
  if (mapType !== undefined) {
    maps = maps.filter(({ value }) => value === mapType);
  }
  return maps
    .map(({ entity, value }) => ({
      entity: entity,
      lootData: getLoot(state, entity),
      mapType: value,
    }))
    .sort((a, b) => a.lootData.ilvl - b.lootData.ilvl);
}

function formatMapType(label: string): Hex {
  return toHex(label, { size: 32 });
}

export const MapTypes = {
  Basic: formatMapType("Basic"),
  Random: formatMapType("Random"),
  "Cycle Boss": formatMapType("Cycle Boss"),
};
