import { CombatReward } from "../components/Combat/CombatReward";
import CustomButton from "../components/UI/Button/CustomButton";
import { useWandererContext } from "../contexts/WandererContext";
import { CombatResult } from "../mud/hooks/combat";
import { useBlockNumber } from "../mud/hooks/useBlockNumber";

export function CombatResultPage() {
  // TODO add a setter to context that on encounter completion caches that fact, and then the result
  const { selectedWandererEntity, combatRewardRequests, lastCombatResult, clearCombatResult } = useWandererContext();
  // TODO generalize result page with entity as required param?
  if (!selectedWandererEntity) throw new Error("Invalid selected wanderer entity");

  const currentBlockNumber = useBlockNumber();

  // TODO use combatRewardRequest.mapEntity to repeat the map (with nonglobal maps this will get complicated)

  // TODO combatRewardRequests should try to autoclaim maybe? that could get tricky with gas

  const withResult = lastCombatResult !== undefined;

  return (
    <section className="flex justify-center w-full">
      <div className="p-2 flex justify-around flex-col w-64 h-36 border border-dark-400 mt-10 items-center">
        <h3 className="text-center text-dark-string">
          {withResult ? CombatResult[lastCombatResult.combatResult] : "Unclaimed combat rewards"}
        </h3>

        <div>
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
            <span>loading...</span>
          )}
        </div>

        {withResult && combatRewardRequests.length === 0 && (
          <div className="flex justify-around w-full">
            <CustomButton onClick={() => console.log("TODO onMapRepeat")}>Repeat</CustomButton>
            <CustomButton onClick={() => clearCombatResult()}>Close</CustomButton>
          </div>
        )}
      </div>
    </section>
  );
}
