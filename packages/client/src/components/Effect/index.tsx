import { useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useDuration } from "../../mud/hooks/useDuration";
import { AppliedEffect, EffectRemovability } from "../../mud/hooks/useEffectPrototype";
import { EffectModifier } from "./EffectStatmod";
import EffectNameItem from "./EffectNameItem";
import EffectNameSkill from "./EffectNameSkill";

export default function Effect({ entity, protoEntity, removability, statmods, isItem, isSkill }: AppliedEffect) {
  const { cycleEntity } = useWandererContext();

  const duration = useDuration(cycleEntity, entity);

  const removeEffect = useCallback(() => {
    console.log("TODO add removeEffect callback");
  }, []);

  return (
    <div className="p-1 bg-dark-600 border border-dark-400">
      <div className="overflow-hidden text-ellipsis whitespace-nowrap">
        {protoEntity && isItem && <EffectNameItem entity={protoEntity} />}
        {protoEntity && isSkill && <EffectNameSkill entity={protoEntity} />}
      </div>

      {statmods &&
        statmods.map(({ protoEntity, value }) => (
          <EffectModifier key={protoEntity} protoEntity={protoEntity} value={value} />
        ))}

      {duration !== undefined && duration.timeValue > 0 && (
        <div className="text-sm">
          <span className="text-dark-key">{duration.timeScopeName}</span>
          <span className="text-dark-number">{duration.timeValue}</span>)
        </div>
      )}

      {/* TODO replace with a working button */}
      {/*removability === EffectRemovability.BUFF &&
        <MethodButton name="remove" className="text-sm"
          onClick={() => removeEffect()} />
      */}
    </div>
  );
}
