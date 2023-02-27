import CustomButton from "../components/UI/Button/CustomButton";
import { useWandererContext } from "../contexts/WandererContext";
import { useClaimCycleCombatReward } from "../mud/hooks/combat";

export function CombatResultPage() {
  // TODO add a setter to context that on encounter completion caches that fact, and then the result
  const { selectedWandererEntity, combatRewardRequests } = useWandererContext();
  // TODO generalize result page with entity as required param?
  if (!selectedWandererEntity) throw new Error("Invalid selected wanderer entity");

  const claimCycleCombatReward = useClaimCycleCombatReward();

  /* TODO get current blocknumber and on this condition allow clearing the obsolete reward
    if (currentBlocknumber > combatRewardRequest.blocknumber + 256) {
      UNAVAILABLE
    }
  */

  // TODO use combatRewardRequest.mapEntity to repeat the map (with nonglobal maps this will get complicated)

  // TODO combatRewardRequests should try to autoclaim maybe? that could get tricky with gas

  return (
    <section className="p-2 flex justify-around flex-col w-64 h-36 border border-dark-400 mt-10 ">
      <h3 className="text-center text-dark-string">Result</h3>
      <div>
        {/* TODO styles */}
        {combatRewardRequests.map(({ requestEntity }) => (
          <button key={requestEntity} onClick={() => claimCycleCombatReward(selectedWandererEntity, requestEntity)}>
            claim reward
          </button>
        ))}
      </div>
      {/* TODO disable/hide buttons until all rewards are claimed/unavailable */}
      <div className="flex justify-center w-full">
        <CustomButton>{"repeat"}</CustomButton>
        <CustomButton>{"close"}</CustomButton>
      </div>
    </section>
  );
}
