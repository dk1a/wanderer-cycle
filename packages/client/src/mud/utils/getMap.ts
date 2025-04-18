import { Hex, toHex } from "viem";
import { getRecord, getRecords } from "@latticexyz/stash/internal";
import { mudTables, StateLocal } from "../stash";
import { getLoot, LootData } from "./getLoot";

export interface MapData {
  entity: Hex;
  lootData: LootData;
  mapType: Hex;
}

export function getMap(
  state: StateLocal,
  entity: Hex | undefined,
): MapData | undefined {
  if (entity === undefined) return;
  const map = getRecord({
    state,
    table: mudTables.root__MapTypeComponent,
    key: { entity },
  });
  if (map === undefined) return;

  return {
    entity: entity,
    lootData: getLoot(state, entity),
    mapType: map.value,
  };
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

export function getFromMap(
  state: StateLocal,
  encounterEntity: Hex | undefined,
): MapData | undefined {
  if (encounterEntity === undefined) return;
  const fromMap = getRecord({
    state,
    table: mudTables.root__FromMap,
    key: { encounterEntity },
  });
  if (fromMap === undefined) return;
  return getMap(state, fromMap.mapEntity);
}

function formatMapType(label: string): Hex {
  return toHex(label, { size: 32 });
}

export const MapTypes = {
  Basic: formatMapType("Basic"),
  Random: formatMapType("Random"),
  "Cycle Boss": formatMapType("Cycle Boss"),
};
