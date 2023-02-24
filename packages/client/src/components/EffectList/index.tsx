import { useMemo } from "react";
import { AppliedEffect, EffectSource } from "../../mud/utils/getEffect";
import EffectListSection from "./EffectListSection";

interface EffectListProps {
  effects: AppliedEffect[] | undefined;
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
    sources: [EffectSource.NFT, EffectSource.OWNABLE],
    sourceName: "item",
    isInitCollapsed: true,
  },
  {
    sources: [EffectSource.UNKNOWN],
    sourceName: "skill",
    isInitCollapsed: false,
  },
];

export default function EffectList({ effects }: EffectListProps) {
  const groupedEffects = useMemo(() => {
    if (!effects) return [];
    const result = [];
    for (const effectGroup of effectGroups) {
      const effectsForGroup = effects.filter(({ effectSource }) => effectGroup.sources.includes(effectSource));
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
    <div className="col-span-3 space-y-2">
      <h5 className="text-dark-comment">{"// effects"}</h5>

      {groupedEffects.map(({ sourceName, effects, isInitCollapsed }) => (
        <EffectListSection key={sourceName} sourceName={sourceName} effects={effects} initCollapsed={isInitCollapsed} />
      ))}
    </div>
  );
}
