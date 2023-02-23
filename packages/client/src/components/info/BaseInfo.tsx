import { EntityIndex } from "@latticexyz/recs";
import { Fragment, ReactNode } from "react";
import { useLife, useMana } from "../../mud/hooks/charstat";
import { useLifeCurrent } from "../../mud/hooks/useLifeCurrent";
import { useManaCurrent } from "../../mud/hooks/useManaCurrent";
import StatLevelProgress, { StatLevelProgressProps } from "./StatLevelProgress";
// import EffectList from "../../EffectList";

export interface StatProps {
  name: string;
  props: StatLevelProgressProps;
}

export interface BaseInfoProps {
  entity: EntityIndex | undefined;
  name: string | undefined;
  locationName: string | null | undefined;
  levelProps: StatProps;
  statProps: StatProps[];
  turnsHtml?: ReactNode;
}

export default function BaseInfo({ entity, name, locationName, levelProps, statProps, turnsHtml }: BaseInfoProps) {
  const life = useLife(entity);
  const mana = useMana(entity);

  const lifeCurrent = useLifeCurrent(entity);
  const manaCurrent = useManaCurrent(entity);

  const currents = [
    {
      name: "life",
      value: lifeCurrent,
      maxValue: life,
    },
    {
      name: "mana",
      value: manaCurrent,
      maxValue: mana,
    },
  ];

  const separator = <hr className="h-px my-2 bg-dark-400 border-0" />;

  return (
    <section className="flex flex-col w-64 bg-dark-500 border border-dark-400 h-[100vh]">
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
      {currents.map(({ name, value, maxValue }) => (
        <Fragment key={name}>
          <div className="text-dark-key flex m-2">
            {name}:
            <div className="text-dark-key flex mx-2">
              <span className="text-dark-number">{value}</span>
              <span className="text-dark-200 mx-0.5">/</span>
              <span className="text-dark-number">{maxValue}</span>
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
