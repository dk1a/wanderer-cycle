import { ReactNode } from "react";
import { StatLevelProgressProps } from "../info/StatLevelProgress";
import BaseInfo from "../info/BaseInfo";
import { EntityIndex } from "@latticexyz/recs";

export interface StatProps {
  name: string;
  props: StatLevelProgressProps;
}

export interface BaseInfoProps {
  entity: EntityIndex;
  name: string | undefined;
  locationName: string | null | undefined;
  levelProps: StatProps;
  statProps: StatProps[];
  lifeCurrent: number | undefined;
  manaCurrent: number | undefined;
  turnsHtml?: ReactNode;
}

export default function CombatInfo({
  entity,
  name,
  locationName,
  levelProps,
  statProps,
  lifeCurrent,
  manaCurrent,
}: BaseInfoProps) {
  return (
    <BaseInfo
      entity={entity}
      name={name}
      locationName={locationName}
      levelProps={levelProps}
      statProps={statProps}
      lifeCurrent={lifeCurrent}
      manaCurrent={manaCurrent}
    />
  );
}
