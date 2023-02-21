import { Fragment, ReactNode } from "react";
import StatLevelProgress, { StatLevelProgressProps } from "../StatLevelProgress";
// import EffectList from "../../EffectList";

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

  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;

  return (
    <section className="flex flex-col w-52 bg-dark-500 border border-dark-400 h-[100vh]">
      <h4 className="relative col-span-3 text-center text-lg text-dark-type font-medium">{name}</h4>
      {locationName !== null && <div className="col-span-3 text-center text-dark-string">{locationName}</div>}
      <div className="text-dark-key p-2 flex">
        <span className="w-36">
          {levelProps.name}: <span className="text-dark-number">{levelProps.props.level}</span>
        </span>
        <StatLevelProgress {...levelProps.props} />
      </div>
      {separator}
      {statProps.map(({ name, props }) => (
        <Fragment key={name}>
          <div className="text-dark-key p-2 flex">
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
          <div className="text-dark-key flex m-2">
            {name}:
            <div className="text-dark-key flex mx-2">
              <span className="text-dark-number">{value}</span>
              <span className="text-dark-200 m-0.5 ">/</span>
              <span className="text-dark-number">123{/* TODO statmod goes here */}</span>
            </div>
          </div>
          <div className="flex m-1">
            {/* TODO regen statmods. They are often absent and shouldn't be displayed */}
            <>
              {/*<span className='text-dark-key'>regen:</span>*/}
              {/*<span className='text-dark-key'>5</span>*/}
            </>
          </div>
        </Fragment>
      ))}
      {turnsHtml}
      {/* TODO elemental stats */}
      <div className="col-span-3">
        <h5 className="text-dark-comment ml-1">{"// elemental"}</h5>
        {/*{attrs && <ElementalStats attrs={attrs} />}*/}
      </div>
      {separator}
      {/*<EffectList />*/}
    </section>
  );
}
