import { useMemo } from "react";
import { AppliedEffect } from "../../mud/hooks/useEffectPrototype";
import EffectListSection from "./EffectListSection";

interface EffectListProps {
  effects: AppliedEffect[] | undefined;
}

export default function EffectList({ effects }: EffectListProps) {
  const effectLists = useMemo(() => {
    if (!effects) return [];
    const skillEffects = effects.filter(({ isSkill }) => isSkill);
    const itemEffects = effects.filter(({ isItem }) => isItem);

    const result = [];
    if (skillEffects.length > 0) {
      result.push({ sourceName: "skill", effectList: skillEffects, isInitCollapsed: false });
    }
    if (itemEffects.length > 0) {
      result.push({ sourceName: "item", effectList: itemEffects, isInitCollapsed: true });
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
