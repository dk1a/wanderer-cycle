import { useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useDuration } from "../../mud/hooks/useDuration";
import { EffectStatmod } from "./EffectStatmod";
import EffectNameItem from "./EffectNameItem";
import EffectNameSkill from "./EffectNameSkill";
import { AppliedEffect, EffectSource } from "../../mud/utils/getEffect";

export default function Effect({ entity, protoEntity, removability, statmods, effectSource }: AppliedEffect) {
  const { cycleEntity } = useWandererContext();

  const duration = useDuration(cycleEntity, entity);

  const removeEffect = useCallback(() => {
    console.log("TODO add removeEffect callback");
  }, []);

  const isItem = effectSource === EffectSource.NFT || effectSource === EffectSource.OWNABLE;

  return (
    <div className="p-1 bg-dark-600 border border-dark-400">
      <div className="overflow-hidden text-ellipsis whitespace-nowrap">
        {protoEntity && isItem && <EffectNameItem entity={protoEntity} />}
        {protoEntity && effectSource === EffectSource.SKILL && <EffectNameSkill entity={protoEntity} />}
        {EffectSource.UNKNOWN == effectSource && `Unknown ${protoEntity}`}
      </div>

      {statmods &&
        statmods.map(({ protoEntity, value }) => (
          <EffectStatmod key={protoEntity} protoEntity={protoEntity} value={value} />
        ))}

      {duration !== undefined && duration.timeValue > 0 && (
        <div className="text-sm">
          <span className="text-dark-key">{duration.timeScopeName}</span>
          <span className="text-dark-number">{duration.timeValue}</span>
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
