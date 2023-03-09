import { useWandererContext } from "../../contexts/WandererContext";
import CombatActions from "./CombatActions";
import { CombatRoundOutcome } from "./CombatRoundOutcome";

export function Combat() {
  const { lastCombatResult } = useWandererContext();
  return (
    <section className="p-2 flex flex-col justify-center items-center w-full">
      {/* TODO re-enable after implementing rounds
      <div className="flex justify-center">
        <span className="text-dark-key text-xl">rounds: </span>
        <span className="m-0.5 ml-1 text-dark-number">{1}</span>
        <span className="m-0.5">/</span>
        <span className="m-0.5 text-dark-number">{MAX_ROUNDS}</span>
      </div>
      */}
      <div className="flex justify-center w-1/2">
        <div className="text-2xl text-dark-type mr-2">selected map</div>
      </div>
      {lastCombatResult !== undefined && <CombatRoundOutcome lastCombatResult={lastCombatResult} />}
      <CombatActions />
    </section>
  );
}
