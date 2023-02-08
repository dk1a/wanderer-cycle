import { Fragment, ReactNode } from "react";
import StatLevelProgress, { StatLevelProgressProps } from "./StatLevelProgress";
import EffectList from "../EffectList";

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

  const separator = <div className="col-span-3 mt-1 mb-1 border-b border-dark-400" />;

  return (
    <section className="grid grid-cols-3 items-center">
      <h4 className="relative col-span-3 text-center text-lg text-dark-type">{name}</h4>

      {locationName !== null && <div className="col-span-3 text-center text-dark-string">{locationName}</div>}

      <div className="text-dark-key">{levelProps.name}:</div>
      <StatLevelProgress {...levelProps.props} />

      {separator}

      {statProps.map(({ name, props }) => (
        <Fragment key={name}>
          <div className="text-dark-key">{name}:</div>
          <StatLevelProgress {...props} />
        </Fragment>
      ))}

      {separator}

      {currents.map(({ name, value }) => (
        <Fragment key={name}>
          <div className="text-dark-key">{name}:</div>
          <div className="flex-default">
            <span className="number-item">{value}</span>
            <span className="w-4 text-center">/</span>
            <span className="number-item">123{/* TODO statmod goes here */}</span>
          </div>
          <div className="flex-default">
            {/* TODO regen statmods. They are often absent and shouldn't be displayed */}
            <>
              <span className="text-dark-key">regen:</span>
              <span className="w-4 text-center text-dark-number">5</span>
            </>
          </div>
        </Fragment>
      ))}

      {turnsHtml}

      {separator}

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
