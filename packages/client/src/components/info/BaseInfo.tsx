import { EntityIndex } from "@latticexyz/recs";
import { Fragment, ReactNode } from "react";
import { LevelData, useLife, useMana, usePstats } from "../../mud/hooks/charstat";
import { useAppliedEffects } from "../../mud/hooks/useAppliedEffects";
import { useLifeCurrent, useManaCurrent, useIdentityCurrent } from "../../mud/hooks/currents";
import { ElementalStatmods } from "../ElementalStatmods";
import { PStatWithProgress } from "./PStatWithProgress";
import EffectList from "../EffectList";

export interface BaseInfoProps {
  entity: EntityIndex | undefined;
  name: string | undefined;
  locationName: string | null | undefined;
  levelData: LevelData;
  turnsHtml?: ReactNode;
}

export default function BaseInfo({ entity, name, locationName, levelData, turnsHtml }: BaseInfoProps) {
  const pstats = usePstats(entity);

  const life = useLife(entity);
  const mana = useMana(entity);

  const identityCurrent = useIdentityCurrent(entity);
  const lifeCurrent = useLifeCurrent(entity);
  const manaCurrent = useManaCurrent(entity);

  const effects = useAppliedEffects(entity);

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

  const separator = <hr className="h-px my-2 bg-dark-400 border-0 " />;

  return (
    <section className="flex flex-col w-64 bg-dark-500 border border-dark-400 h-full">
      <h4 className="relative col-span-3 text-center text-lg text-dark-type font-medium">{name}</h4>
      {locationName !== null && <div className="col-span-3 text-center text-dark-string">{locationName}</div>}

      {identityCurrent !== undefined && (
        <span className="w-36 text-dark-key ml-1">
          {"identity: "}
          <span className="text-dark-number">{identityCurrent}</span>
        </span>
      )}

      <PStatWithProgress name={"level"} baseLevel={levelData?.level} experience={levelData?.experience} />
      {separator}
      {pstats.map((pstat) => (
        <PStatWithProgress key={pstat.name} {...pstat} />
      ))}

      {separator}
      {currents.map(({ name, value, maxValue }) => (
        <Fragment key={name}>
          <div className="text-dark-key flex mx-2">
            {name}:
            <div className="text-dark-key flex mx-2">
              <span className="text-dark-number">{value}</span>
              <span className="text-dark-200 mx-0.5">/</span>
              <span className="text-dark-number">{maxValue}</span>
            </div>
          </div>
          {/*<div className="flex m-1">*/}
          {/*  /!* TODO regen statmods. They are often absent and shouldn't be displayed *!/*/}
          {/*  <>*/}
          {/*    /!*<span className='text-dark-key'>regen:</span>*!/*/}
          {/*    /!*<span className='text-dark-key'>5</span>*!/*/}
          {/*  </>*/}
          {/*</div>*/}
        </Fragment>
      ))}
      {turnsHtml}
      {/* TODO styles, this is from old ui and looks terrible */}
      {separator}
      <ElementalStatmods />
      {separator}
      <EffectList effects={effects} />
    </section>
  );
}
