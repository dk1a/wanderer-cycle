//import { useCallback } from "react";
import { EffectAppliedData } from "../../mud/utils/getEffect";
import { EffectName } from "./EffectName";
import { EffectStatmods } from "./EffectStatmods";

export function EffectApplied({
  applicationEntity,
  statmods,
  effectSource,
  duration,
}: EffectAppliedData) {
  /*const removeEffect = useCallback(() => {
    console.log("TODO add removeEffect callback");
  }, []);*/

  return (
    <div className="p-1.5 border border-dark-400">
      <div className="overflow-hidden text-ellipsis whitespace-nowrap">
        <EffectName entity={applicationEntity} effectSource={effectSource} />
      </div>

      {statmods && <EffectStatmods statmods={statmods} />}

      {duration !== undefined && duration.timeValue > 0 && (
        <div className="text-sm">
          (<span className="text-dark-number">{duration.timeValue} </span>
          <span className="text-dark-string">{duration.timeId}</span>)
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
