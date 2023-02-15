import { useMaps } from "../../mud/hooks/useMaps";
import { Fragment, ReactNode } from "react";
import { StatLevelProgressProps } from "../info/StatLevelProgress";
import classes from "./combatInfo.module.css";

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
  const mapEntityes = useMaps("Global Basic");

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

  const separator = <div className={classes.separator} />;

  return (
    <div className="absolute top-0 right-0 bg-dark-500 border border-dark-400 h-full w-36 flex items-center flex-col p-4">
      <h4 className={classes.info__header}>{name}</h4>
      {locationName !== null && <div className={classes.info__locationName}>{locationName}</div>}
      <div className={classes.info__level}>
        <span className="w-36">
          {levelProps.name}: <span className="text-dark-number">{levelProps.props.level}</span>
        </span>
      </div>
      {separator}
      {statProps.map(({ name, props }) => (
        <Fragment key={name}>
          <div className={classes.info__level}>
            <span className="w-36">
              {name}: <span className="text-dark-number">{levelProps.props.level}</span>
            </span>
          </div>
        </Fragment>
      ))}
      {separator}
      {currents.map(({ name, value }) => (
        <Fragment key={name}>
          <div className={classes.info__stats}>
            {name}:
            <div className={classes.stats}>
              <span className={classes.stats__number}>{value}</span>
              <span className={classes.stats__number_slash}>/</span>
              <span className={classes.stats__number}>123</span>
            </div>
          </div>
        </Fragment>
      ))}
    </div>
  );
}
