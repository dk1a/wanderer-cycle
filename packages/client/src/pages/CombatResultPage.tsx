import { useCallback, useEffect, useMemo, useState } from "react";
import CustomButton from "../components/UI/Button/CustomButton";
import { useWandererContext } from "../contexts/WandererContext";
import { CombatResult, useActivateCycleCombat } from "../mud/hooks/combat";
import { useBlockNumber } from "../mud/hooks/useBlockNumber";
import { CombatRoundOutcome } from "../components/Combat/CombatRoundOutcome";
import { CombatReward } from "../components/Combat/CombatReward";

export function CombatResultPage() {
  const { selectedWandererEntity, enemyEntity, combatRewardRequests, lastCombatResult, clearCombatResult } =
    useWandererContext();
  // TODO generalize result page with entity as required param?
  if (!selectedWandererEntity) throw new Error("Invalid selected wanderer entity");

  const currentBlockNumber = useBlockNumber();

  // TODO combatRewardRequests should try to autoclaim maybe? that could get tricky with gas

  const activateCycleCombat = useActivateCycleCombat();
  const repeatMapEntity = useMemo(() => {
    // TODO use lastCombatResult when it gets map data
    if (combatRewardRequests.length === 1 && lastCombatResult !== undefined) {
      return combatRewardRequests[0].mapEntity;
    } else {
      return undefined;
    }
  }, [combatRewardRequests, lastCombatResult]);
  const onMapRepeat = useCallback(() => {
    if (!selectedWandererEntity) throw new Error("No selected wanderer entity");
    if (repeatMapEntity === undefined) throw new Error("Invalid map entity");
    activateCycleCombat(selectedWandererEntity, repeatMapEntity);
  }, [activateCycleCombat, selectedWandererEntity, repeatMapEntity]);

  const [dots, setDots] = useState(1);

  useEffect(() => {
    const interval = setInterval(() => {
      setDots((prevDots) => (prevDots === 1 ? 2 : prevDots === 2 ? 3 : 1));
    }, 500);
    return () => clearInterval(interval);
  }, []);

  return (
    <section className="flex flex-col items-center w-full mr-64">
      {lastCombatResult !== undefined && (
        <div>
          <CombatRoundOutcome lastCombatResult={lastCombatResult} />
        </div>
      )}

      <div className="p-2 flex justify-around flex-col h-52 border border-dark-400 mt-10 items-center w-1/3">
        <h3 className="text-center text-dark-string text-xl">
          {lastCombatResult !== undefined ? CombatResult[lastCombatResult.combatResult] : "Unclaimed combat rewards"}
        </h3>
        <div className="w-1/3">
          {selectedWandererEntity !== undefined && currentBlockNumber !== undefined ? (
            combatRewardRequests.map((rewardRequest) => (
              <CombatReward
                key={rewardRequest.requestEntity}
                requesterEntity={selectedWandererEntity}
                currentBlockNumber={currentBlockNumber}
                rewardRequest={rewardRequest}
              />
            ))
          ) : (
            <div className="flex items-center w-full">
              <span className="text-dark-200 w-1/2">Loading</span>
              <div className="flex items-center justify-center w-1/3 text-dark-control ">
                {[...Array(dots)].map((_, index) => (
                  <div key={index} className="">
                    <span>.</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="flex justify-around w-full">
          {selectedWandererEntity && repeatMapEntity && (
            <div className="">
              <CustomButton onClick={onMapRepeat} style={{ width: "9rem" }}>
                Repeat
              </CustomButton>
            </div>
          )}
          {enemyEntity === undefined && combatRewardRequests.length === 0 && (
            <div>
              <CustomButton style={{ width: "9rem" }} onClick={clearCombatResult}>
                Close
              </CustomButton>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
