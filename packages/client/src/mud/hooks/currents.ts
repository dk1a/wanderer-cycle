import { useComponentValue } from "@latticexyz/react";
import { Entity } from "@latticexyz/recs";
import { useMUD } from "../../MUDContext";

export const useLifeCurrent = (entity: Entity | undefined) => {
  const {
    components: { LifeCurrent },
  } = useMUD();

  const lifeCurrent = useComponentValue(LifeCurrent, entity);

  return lifeCurrent?.value;
};

export const useManaCurrent = (entity: Entity | undefined) => {
  const {
    components: { ManaCurrent },
  } = useMUD();

  const manaCurrent = useComponentValue(ManaCurrent, entity);

  return manaCurrent?.value;
};

export const useIdentityCurrent = (entity: Entity | undefined) => {
  const {
    components: { Identity },
  } = useMUD();

  const identityCurrent = useComponentValue(Identity, entity);

  return identityCurrent?.value;
};
