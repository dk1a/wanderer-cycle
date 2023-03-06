import { useComponentValue } from "@latticexyz/react";
import { EntityIndex } from "@latticexyz/recs";
import { useMUD } from "../MUDContext";

export const useLifeCurrent = (entity: EntityIndex | undefined) => {
  const {
    components: { LifeCurrent },
  } = useMUD();

  const lifeCurrent = useComponentValue(LifeCurrent, entity);

  return lifeCurrent?.value;
};

export const useManaCurrent = (entity: EntityIndex | undefined) => {
  const {
    components: { ManaCurrent },
  } = useMUD();

  const manaCurrent = useComponentValue(ManaCurrent, entity);

  return manaCurrent?.value;
};

export const useIdentityCurrent = (entity: EntityIndex | undefined) => {
  const {
    components: { Identity },
  } = useMUD();

  const identityCurrent = useComponentValue(Identity, entity);

  return identityCurrent?.value;
};
