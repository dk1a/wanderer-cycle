import { getRecord } from "@latticexyz/stash/internal";
import { Hex } from "viem";
import { mudTables, StateLocal } from "../stash";

export function getLifeCurrent(state: StateLocal, entity: Hex | undefined) {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.charstat__LifeCurrent,
    key: { entity },
  })?.value;
}

export function getManaCurrent(state: StateLocal, entity: Hex | undefined) {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.charstat__ManaCurrent,
    key: { entity },
  })?.value;
}

export function getIdentityCurrent(state: StateLocal, entity: Hex | undefined) {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.wheel__IdentityCurrent,
    key: { wandererEntity: entity },
  })?.value;
}
