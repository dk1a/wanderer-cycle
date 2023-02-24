import { EntityID } from "@latticexyz/recs";

export const MAX_ROUNDS = 12;

export interface CombatAction {
  actionType: ActionType;
  actionEntity: EntityID;
}

export enum ActionType {
  ATTACK,
  SKILL,
}

export const attackAction: CombatAction = {
  actionType: ActionType.ATTACK,
  actionEntity: "0x00" as EntityID,
};
