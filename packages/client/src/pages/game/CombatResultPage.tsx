import { useCallback, useMemo } from "react";
import { useWandererContext } from "../../mud/WandererProvider";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { CycleCombatRewardRequest } from "../../mud/utils/combat";
import { CombatReward } from "../../components/combat/CombatReward";
// import {CombatRoundOutcome} from "../../components/Combat/CombatRoundOutcome";
import { Button } from "../../components/ui/Button";
import { useStashCustom } from "../../mud/stash";
import { getSyncStatus } from "../../mud/getSyncStatus";

interface CombatResultPageProps {
  combatRewardRequests: CycleCombatRewardRequest[];
}

export function CombatResultPage({
  combatRewardRequests,
}: CombatResultPageProps) {
  const systemCalls = useSystemCalls();
  const { selectedWandererEntity, cycleEntity, enemyEntity } =
    useWandererContext();

  if (!selectedWandererEntity)
    throw new Error("Invalid selected wanderer entity");

  const latestBlockNumber = useStashCustom(
    (state) => getSyncStatus(state).latestBlockNumber,
  );

  const repeatMapEntity = useMemo(() => {
    if (combatRewardRequests.length === 1) {
      return combatRewardRequests[0].mapEntity;
    }
    return undefined;
  }, [combatRewardRequests]);

  const onMapRepeat = useCallback(() => {
    if (!cycleEntity) throw new Error("No cycle entity");
    if (repeatMapEntity === undefined) throw new Error("Invalid map entity");
    systemCalls.cycle.activateCombat(cycleEntity, repeatMapEntity);
  }, [cycleEntity, repeatMapEntity, systemCalls]);

  return (
    <section className="flex flex-col items-center w-full mr-64">
      {/*{lastCombatResult !== undefined && (*/}
      {/*  <div>*/}
      {/*    <CombatRoundOutcome lastCombatResult={lastCombatResult} />*/}
      {/*  </div>*/}
      {/*)}*/}

      <div className="p-2 flex justify-around flex-col h-52 border border-dark-400 mt-10 items-center w-1/3">
        <h3 className="text-center text-dark-string text-xl">
          {/*{lastCombatResult !== undefined ? CombatResult[lastCombatResult.combatResult] : "Unclaimed combat rewards"}*/}
        </h3>

        <div>
          {selectedWandererEntity !== undefined &&
          latestBlockNumber !== undefined ? (
            combatRewardRequests.map((rewardRequest) => (
              <CombatReward
                key={rewardRequest.requestId}
                requesterEntity={selectedWandererEntity}
                latestBlockNumber={latestBlockNumber}
                rewardRequest={rewardRequest}
              />
            ))
          ) : (
            <span>loading...</span>
          )}
        </div>

        <div className="flex justify-around w-full">
          {selectedWandererEntity && repeatMapEntity && (
            <div className="">
              <Button onClick={onMapRepeat} style={{ width: "9rem" }}>
                Repeat
              </Button>
            </div>
          )}
          {enemyEntity === undefined && combatRewardRequests.length === 0 && (
            <div>
              <Button
                style={{ width: "9rem" }}
                // onClick={clearCombatResult}
              >
                Close
              </Button>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
