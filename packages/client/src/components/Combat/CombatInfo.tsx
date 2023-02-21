import { ReactNode } from "react";
import { StatLevelProgressProps } from "../info/StatLevelProgress";
import BaseInfo from "../info/BaseInfo";

export interface StatProps {
  name: string;
  props: StatLevelProgressProps;
}

export interface BaseInfoProps {
  name: string | undefined;
  locationName: string | null | undefined;
  levelProps: StatProps;
  statProps: StatProps[];
  lifeCurrent: number | undefined;
  manaCurrent: number | undefined;
  turnsHtml?: ReactNode;
}

export default function CombatInfo({
  name,
  locationName,
  levelProps,
  statProps,
  lifeCurrent,
  manaCurrent,
}: BaseInfoProps) {
  return (
    <BaseInfo
      name={name}
      locationName={locationName}
      levelProps={levelProps}
      statProps={statProps}
      lifeCurrent={lifeCurrent}
      manaCurrent={manaCurrent}
    />
  );
}
