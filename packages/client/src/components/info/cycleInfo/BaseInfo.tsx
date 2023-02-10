import { Fragment, ReactNode } from "react";
import StatLevelProgress, { StatLevelProgressProps } from "../levelProgress/StatLevelProgress";
import EffectList from "../../EffectList";
import classes from "./info.module.scss";

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

export default function BaseInfo({
  name,
  locationName,
  levelProps,
  statProps,
  lifeCurrent,
  manaCurrent,
  turnsHtml,
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

  const separator = <div className={classes.separator} />;

  return (
    <section className={classes.info__container}>
      <h4 className={classes.info__header}>{name}</h4>
      {locationName !== null && <div className={classes.info__locationName}>{locationName}</div>}
      <div className={classes.info__level}>
        <span className="w-36">
          {levelProps.name}: <span className="text-dark-number">{levelProps.props.level}</span>
        </span>
        <StatLevelProgress {...levelProps.props} />
      </div>
      {separator}
      {statProps.map(({ name, props }) => (
        <Fragment key={name}>
          <div className={classes.info__level}>
            <span className="w-36">
              {name}: <span className="text-dark-number">{levelProps.props.level}</span>
            </span>
            <StatLevelProgress {...props} />
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
              <span className={classes.stats__number}>/</span>
              <span className={classes.stats__number}>123{/* TODO statmod goes here */}</span>
            </div>
          </div>
          <div className={classes.stats__regen}>
            {/* TODO regen statmods. They are often absent and shouldn't be displayed */}
            <>
              <span className={classes.stats__regen_name}>regen:</span>
              <span className={classes.stats__regen_name}>5</span>
            </>
          </div>
        </Fragment>
      ))}
      {turnsHtml}
      {/* TODO elemental stats */}
      {/*<div className="col-span-3">
        <h5 className="text-dark-comment">
          {'// elemental'}
        </h5>
        {attrs && <ElementalStats attrs={attrs} />}
      </div>*/}
      {separator}
      <EffectList />
    </section>
  );
}
