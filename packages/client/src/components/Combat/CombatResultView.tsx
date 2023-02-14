import { useCallback } from "react";
import { EncounterResult, encounterResultNames } from "../../constants";
import { useCallStaticEncounterContext } from "../../contexts/CallStaticEncounterContext";

export default function EncounterResultView({ encounterResult }: { encounterResult: EncounterResult }) {
  const { setLocationId, setEncounterResult } = useCallStaticEncounterContext();

  const onRepeat = useCallback(() => {
    setEncounterResult(EncounterResult.NONE);
  }, [setEncounterResult]);

  const onClose = useCallback(() => {
    setLocationId(undefined);
    setEncounterResult(EncounterResult.NONE);
  }, [setLocationId, setEncounterResult]);

  return (
    <section className="p-2">
      <div className="text-center text-dark-string">{encounterResultNames[encounterResult]}</div>

      <div className="flex-default justify-center mt-1">
        <button type="button" className="btn-control w-28" onClick={onRepeat}>
          repeat
        </button>
        <button type="button" className="btn-control w-28" onClick={onClose}>
          close
        </button>
      </div>
    </section>
  );
}
