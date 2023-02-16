import { Fragment, ReactNode } from "react";
import { StatLevelProgressProps } from "../info/StatLevelProgress";

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

// TODO this should return BaseInfo with different props, not duplicate it (add more props to BaseInfo if needed)
export default function CombatInfo({
  name,
  locationName,
  levelProps,
  statProps,
  lifeCurrent,
  manaCurrent,
}: BaseInfoProps) {
  const currents = [
    {
      name: "life",
      value: lifeCurrent,
    },
    {
      name: "mana",
      value: manaCurrent,
    },
  ];

  const separator = <div className="my-1 border-b border-dark-400" />;

  return (
    <div className="absolute top-0 right-0 bg-dark-500 border border-dark-400 h-full w-36 flex items-center flex-col p-4">
      <h4 className="relative col-span-3 text-center text-lg text-dark-type font-medium">{name}</h4>
      {locationName !== null && <div className="col-span-3 text-center text-dark-string">{locationName}</div>}
      <div className="text-dark-key p-2 flex">
        <span className="w-36">
          {levelProps.name}: <span className="text-dark-number">{levelProps.props.level}</span>
        </span>
      </div>
      {separator}
      {statProps.map(({ name, props }) => (
        <Fragment key={name}>
          <div className="text-dark-key p-2 flex">
            <span className="w-36">
              {name}: <span className="text-dark-number">{levelProps.props.level}</span>
            </span>
          </div>
        </Fragment>
      ))}
      {separator}
      {currents.map(({ name, value }) => (
        <Fragment key={name}>
          <div className="text-dark-key flex m-2">
            {name}:
            <div className="text-dark-key flex m-2">
              <span className="text-dark-number">{value}</span>
              <span className="text-dark-200 m-0.5">/</span>
              <span className="text-dark-number">123</span>
            </div>
          </div>
        </Fragment>
      ))}
    </div>
  );
}
