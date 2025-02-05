import { Entity } from "@latticexyz/recs";
import { Fragment, ReactNode } from "react";
import {
  LevelData,
  useLife,
  useMana,
  usePstats,
} from "../../mud/hooks/charstat";
// import { useAppliedEffects } from "../../mud/hooks/useAppliedEffects";
import {
  useLifeCurrent,
  useManaCurrent,
  useIdentityCurrent,
} from "../../mud/hooks/currents";
import { PStatWithProgress } from "./PStatWithProgress";
import { Tooltip } from "react-tooltip";

export interface BaseInfoProps {
  entity: Entity | undefined;
  name: string | undefined;
  locationName: string | null | undefined;
  levelData: LevelData;
  turnsHtml?: ReactNode;
}

/** Блок для мобильной версии: показ лейбла + контента во всплывашке */
interface MobileInfoBlockProps {
  label: string;
  children: ReactNode;
  className?: string;
}
function MobileInfoBlock({ label, children, className }: MobileInfoBlockProps) {
  const uniqueId = `mobile-info-${label.toLowerCase().replace(/\s+/g, "-")}`;
  return (
    <div
      id={uniqueId}
      className="border border-dark-400 bg-dark-500 p-2 cursor-pointer text-center text-dark-type"
    >
      <div className={className + " font-bold"}>{label}</div>
      <Tooltip anchorSelect={`#${uniqueId}`} place="top" clickable>
        {children}
      </Tooltip>
    </div>
  );
}

export default function BaseInfo({
  entity,
  name,
  locationName,
  levelData,
  turnsHtml,
}: BaseInfoProps) {
  const pstats = usePstats(entity);
  const life = useLife(entity);
  const mana = useMana(entity);
  const identityCurrent = useIdentityCurrent(entity);
  const lifeCurrent = useLifeCurrent(entity);
  const manaCurrent = useManaCurrent(entity);
  // const effects = useAppliedEffects(entity);

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
  const desktopContent = (
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
      {/* {effects.length > 0 && (
        <div className="p-2">
          <h5 className="text-dark-type mb-2">Effects:</h5>
          {effects.map((e, idx) => (
            <div key={idx}>{JSON.stringify(e)}</div>
          ))}
        </div>
      )} */}
    </section>
  );
  const mobileBlockConfigs = [
    {
      condition: !!name,
      label: name ?? "Name",
      className: "text-dark-control",
      content: (
        <div>
          {locationName && <div>Location: {locationName}</div>}
          {identityCurrent !== undefined && (
            <div>Identity: {identityCurrent}</div>
          )}
        </div>
      ),
    },
    {
      condition: levelData && levelData.level !== undefined,
      label: "Level",
      content: (
        <PStatWithProgress
          name="level"
          baseLevel={levelData?.level}
          experience={levelData?.experience}
        />
      ),
    },
    {
      condition: pstats.length > 0,
      label: "Stats",
      content: (
        <div>
          {pstats.map((pstat) => (
            <PStatWithProgress key={pstat.name} {...pstat} />
          ))}
        </div>
      ),
    },
    {
      condition: !!turnsHtml,
      label: "Turns",
      content: <div>{turnsHtml}</div>,
    },
    {
      condition: currents.some(
        (c) => c.value !== undefined && c.maxValue !== undefined,
      ),
      label: "Life/Mana",
      content: (
        <div>
          {currents.map(({ name, value, maxValue }) => {
            if (value === undefined || maxValue === undefined) return null;
            return (
              <div key={name}>
                {name}: {value} / {maxValue}
              </div>
            );
          })}
        </div>
      ),
    },
    // {
    //   // Эффекты
    //   condition: effects && effects.length > 0,
    //   label: "Effects",
    //   content: (
    //     <div>
    //       {effects.map((e, idx) => (
    //         <div key={idx}>{JSON.stringify(e)}</div>
    //       ))}
    //     </div>
    //   ),
    // },
  ];

  const mobileBlocks = mobileBlockConfigs.filter((b) => b.condition);

  const mobileContent = (
    <section className="flex md:hidden fixed bottom-0 left-0 w-full bg-dark-500 border-t border-dark-400 p-2">
      <div className="grid grid-cols-3 grid-rows-2 gap-2 w-full">
        {mobileBlocks.slice(0, 6).map((block) => (
          <MobileInfoBlock
            key={block.label}
            label={block.label}
            className={block.className}
          >
            {block.content}
          </MobileInfoBlock>
        ))}
      </div>
    </section>
  );

  return (
    <>
      {desktopContent}
      {mobileContent}
    </>
  );
}
