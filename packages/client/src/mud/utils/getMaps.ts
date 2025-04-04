import { Hex, toHex } from "viem";
import { StoreState, StoreTables } from "../setup";
import { getLoot, LootData } from "./getLoot";

export interface MapData {
  entity: Hex;
  lootData: LootData;
  mapType: Hex;
}

export function getMaps(
  tables: StoreTables,
  state: StoreState,
  mapType: Hex | undefined,
): MapData[] {
  let maps = Object.values(state.getRecords(tables.MapTypeComponent));
  if (mapType !== undefined) {
    maps = maps.filter(({ value }) => value.value === mapType);
  }
  return maps
    .map(({ key, value }) => ({
      entity: key.entity,
      lootData: getLoot(tables, state, key.entity),
      mapType: value.value,
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
