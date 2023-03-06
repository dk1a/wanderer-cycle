import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useCycleTurns = (entity: EntityIndex | undefined) => {
  const {
    components: { CycleTurns },
  } = useMUD();

  const cycleTurns = useComponentValue(CycleTurns, entity);
  return cycleTurns?.value;
};

export const useCycleTurnsLastClaimedComponent = (entity: EntityIndex | undefined) => {
  const {
    components: { CycleTurnsLastClaimed },
  } = useMUD();

  const cycleTurnsLastClaimed = useComponentValue(CycleTurnsLastClaimed, entity);
  return cycleTurnsLastClaimed?.value;
};
