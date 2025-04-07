import { getRecord } from "@latticexyz/stash/internal";
import { Hex } from "viem";
import { mudTables, StateLocal } from "../stash";

export const getLifeCurrent = (state: StateLocal, entity: Hex | undefined) => {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.root__LifeCurrent,
    key: { entity },
  })?.value;
};

export const getManaCurrent = (state: StateLocal, entity: Hex | undefined) => {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.root__ManaCurrent,
    key: { entity },
  })?.value;
};

export const getIdentityCurrent = (
  state: StateLocal,
  entity: Hex | undefined,
) => {
  if (entity === undefined) return;
  return getRecord({
    state,
    table: mudTables.wheel__IdentityCurrent,
    key: { wandererEntity: entity },
  })?.value;
};
