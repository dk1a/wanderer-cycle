import { useMUD } from "../MUDContext";
import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";

export const useIdentity = (entity: EntityIndex | undefined) => {
  const {
    components: { Identity },
  } = useMUD();

  const identity = useComponentValue(Identity, entity);

  return identity?.value;
};
