import { useMemo, useState } from "react";
import { EffectAppliedData, EffectSource } from "../../mud/utils/getEffect";
import { EffectApplied } from "./EffectApplied";

interface EffectListProps {
  effects: EffectAppliedData[];
}

interface EffectListSectionProps {
  sourceName: string;
  effects: EffectAppliedData[];
  initCollapsed: boolean;
}

const effectGroups = [
  {
    sources: [EffectSource.SKILL],
    sourceName: "skill",
    isInitCollapsed: false,
  },
  {
    sources: [EffectSource.MAP],
    sourceName: "map",
    isInitCollapsed: false,
  },
  {
    sources: [EffectSource.EQUIPMENT],
    sourceName: "equipment",
    isInitCollapsed: true,
  },
  {
    sources: [EffectSource.UNKNOWN],
    sourceName: "unknown",
    isInitCollapsed: false,
  },
];

export function EffectList({ effects }: EffectListProps) {
  const groupedEffects = useMemo(() => {
    const result = [];
    for (const effectGroup of effectGroups) {
      const effectsForGroup = effects.filter(({ effectSource }) =>
        effectGroup.sources.includes(effectSource),
      );
      if (effectsForGroup.length > 0) {
        result.push({
          ...effectGroup,
          effects: effectsForGroup,
        });
      }
    }
    return result;
  }, [effects]);

  return (
    <div className="col-span-3">
      <h5 className="text-dark-comment ml-2">{"// effects"}</h5>

      {groupedEffects.map(({ sourceName, effects, isInitCollapsed }) => (
        <EffectListSection
          key={sourceName}
          sourceName={sourceName}
          effects={effects}
          initCollapsed={isInitCollapsed}
        />
      ))}
    </div>
  );
}

function EffectListSection({
  sourceName,
  effects,
  initCollapsed,
}: EffectListSectionProps) {
  const [collapsed, setCollapsed] = useState(initCollapsed);

  return (
    <div className="col-span-3">
      <h5
        className="cursor-pointer"
        onClick={() => setCollapsed((collapsed) => !collapsed)}
      >
        <span className="text-dark-comment ml-2 mr-1">{`// source: ${sourceName}`}</span>
        <span>{collapsed ? ">" : "v"}</span>
      </h5>

      {!collapsed &&
        effects.map((effect) => (
          <EffectApplied
            key={`${effect.targetEntity}-${effect.applicationEntity}`}
            {...effect}
          />
        ))}
    </div>
  );
}
