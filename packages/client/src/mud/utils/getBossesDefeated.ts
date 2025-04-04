import { Hex } from "viem";
import { StoreState, StoreTables } from "../setup";

export function getBossesDefeated(
  tables: StoreTables,
  state: StoreState,
  entity: Hex,
): readonly Hex[] {
  const mapEntities = state.getValue(tables.BossesDefeated, { entity })?.value;
  return mapEntities ?? [];
}
