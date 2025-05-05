import { Fragment, ReactNode } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import {
  getIdentityCurrent,
  getLifeCurrent,
  getManaCurrent,
} from "../../mud/utils/currents";
import {
  getLife,
  getMana,
  getPStats,
  LevelData,
} from "../../mud/utils/charstat";
import { getEffectsApplied } from "../../mud/utils/getEffect";
import { PStatWithProgress } from "./PStatWithProgress";
import { EffectList } from "../effect/EffectList";

export interface BaseInfoProps {
  entity: Hex | undefined;
  name: string | undefined;
  locationName: string | null | undefined;
  levelData: LevelData;
  turnsHtml?: ReactNode;
}

export function BaseInfo({
  entity,
  name,
  locationName,
  levelData,
  turnsHtml,
}: BaseInfoProps) {
  const pstats = useStashCustom((state) =>
    entity ? getPStats(state, entity) : [],
  );
  const life = useStashCustom((state) => getLife(state, entity));
  const mana = useStashCustom((state) => getMana(state, entity));
  const identityCurrent = useStashCustom((state) =>
    getIdentityCurrent(state, entity),
  );
  const lifeCurrent = useStashCustom((state) => getLifeCurrent(state, entity));
  const manaCurrent = useStashCustom((state) => getManaCurrent(state, entity));

  const effects = useStashCustom((state) =>
    entity ? getEffectsApplied(state, entity) : [],
  );

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
    <section className="hidden md:flex md:flex-col bg-dark-500 border border-dark-400 w-64 md:h-full">
      <h4 className="relative text-center text-lg text-dark-type font-medium">
        {name}
      </h4>

      {locationName !== null && (
        <div className="text-center text-dark-string">{locationName}</div>
      )}

      {identityCurrent !== undefined && (
        <span className="text-dark-key ml-1">
          identity: <span className="text-dark-number">{identityCurrent}</span>
        </span>
      )}
      <PStatWithProgress
        name="level"
        baseLevel={levelData?.level}
        experience={levelData?.experience}
      />
      {separator}
      {pstats.map((pstat) => (
        <PStatWithProgress key={pstat.name} {...pstat} />
      ))}
      {separator}
      {currents.map(({ name, value, maxValue }) => {
        if (value === undefined || maxValue === undefined) return null;
        return (
          <Fragment key={name}>
            <div className="text-dark-key flex mx-2">
              {name}:
              <div className="text-dark-key flex mx-2">
                <span className="text-dark-number">{value}</span>
                <span className="text-dark-200 mx-0.5">/</span>
                <span className="text-dark-number">{maxValue}</span>
              </div>
            </div>
          </Fragment>
        );
      })}
      {turnsHtml}
      {separator}
      <EffectList effects={effects} />
    </section>
  );
}
