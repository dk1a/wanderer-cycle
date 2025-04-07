import { useEffect, useMemo, useState } from "react";
import BaseInfo from "./BaseInfo";
import PassTurnButton from "./PassTurnButton";
import ClaimTurnsButton from "./ClaimTurnsButton";
import { useWandererContext } from "../../contexts/WandererContext";
import { useStashCustom } from "../../mud/stash";
import { getActiveGuise } from "../../mud/utils/guise";
import {
  getAccPeriods,
  getClaimableTurns,
  getCycleTurns,
} from "../../mud/utils/turns";
import { useLevel } from "../../mud/hooks/charstat";

export default function CycleInfo() {
  const { cycleEntity } = useWandererContext();
  const guise = useStashCustom((state) => getActiveGuise(state, cycleEntity));
  const turns = useStashCustom((state) => getCycleTurns(state, cycleEntity));

  const guiseMul = useMemo(() => guise?.levelMul, [guise]);
  const levelData = useLevel(cycleEntity, guiseMul);

  const [timestamp, setTimestamp] = useState(Date.now());

  const { accPeriods, nextClaimableTimestamp } = useStashCustom((state) => {
    if (cycleEntity === undefined)
      return {
        accPeriods: 0,
        nextClaimableTimestamp: undefined,
      };
    return getAccPeriods(state, cycleEntity, timestamp);
  });

  const claimableTurns = useStashCustom((state) => {
    if (cycleEntity === undefined) return;
    return getClaimableTurns(state, cycleEntity, accPeriods);
  });

  useEffect(() => {
    const timeout = setTimeout(() => {
      setTimestamp(Date.now());
    }, nextClaimableTimestamp);

    return () => clearTimeout(timeout);
  }, [nextClaimableTimestamp]);

  const turnsHtml = (
    <div className="flex ml-2">
      <div className="w-1/3 mr-5 flex">
        <span className="text-dark-key">turns:</span>
        <span className="text-dark-number ml-1">{turns}</span>
        <div className="flex">
          <PassTurnButton />
          {claimableTurns !== undefined && claimableTurns > 0 && (
            <div className="w-1/2 mr-0.5">
              <ClaimTurnsButton claimableTurns={claimableTurns} />
            </div>
          )}
        </div>
      </div>
    </div>
  );

  return (
    <div className="top-16 h-full">
      <BaseInfo
        entity={cycleEntity}
        name={guise?.name}
        locationName={null}
        levelData={levelData}
        turnsHtml={turnsHtml}
      />
    </div>
  );
}
