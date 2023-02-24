import { useMemo } from "react";
import { AppliedEffect, EffectSource } from "../../mud/utils/getEffect";
import EffectListSection from "./EffectListSection";

interface EffectListProps {
  effects: AppliedEffect[] | undefined;
}

export default function EffectList({ effects }: EffectListProps) {
  const effectLists = useMemo(() => {
    if (!effects) return [];
    const skillEffects = effects.filter(({ effectSource }) => effectSource === EffectSource.SKILL);
    const itemEffects = effects.filter(({ effectSource }) =>
      [EffectSource.NFT, EffectSource.OWNABLE].includes(effectSource)
    );
    // TODO these shouldn't exist! this is just for debugging
    const unknownEffects = effects.filter(({ effectSource }) => effectSource === EffectSource.UNKNOWN);

    const result = [];
    if (skillEffects.length > 0) {
      result.push({ sourceName: "skill", effectList: skillEffects, isInitCollapsed: false });
    }
    if (itemEffects.length > 0) {
      result.push({ sourceName: "item", effectList: itemEffects, isInitCollapsed: true });
    }
    if (unknownEffects.length > 0) {
      result.push({ sourceName: "unknown", effectList: unknownEffects, isInitCollapsed: true });
    }
    return result;
  }, [effects]);

  return (
    <div className="col-span-3 space-y-2">
      <h5 className="text-dark-comment">{"// effects"}</h5>

      {effectLists.map(({ sourceName, effectList, isInitCollapsed }) => (
        <EffectListSection
          key={sourceName}
          sourceName={sourceName}
          effects={effectList}
          initCollapsed={isInitCollapsed}
        />
      ))}
    </div>
  );
}
