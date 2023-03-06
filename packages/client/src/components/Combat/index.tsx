import { useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { attackAction } from "../../mud/utils/combat";
import CombatActions from "./CombatActions";
import { CombatRoundOutcome } from "./CombatRoundOutcome";

export default function Combat() {
  const { selectedWandererEntity, lastCombatResult } = useWandererContext();
  const executeCycleCombatRound = useExecuteCycleCombatRound();

  const onAttack = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("Must select wanderer entity");
    }
    executeCycleCombatRound(selectedWandererEntity, [attackAction]);
  }, [selectedWandererEntity, executeCycleCombatRound]);

  // ========== RENDER ==========
  return (
    <section className="p-2 flex flex-col justify-center items-center">
      {/* TODO re-enable after implementing rounds
      <div className="flex justify-center">
        <span className="text-dark-key text-xl">rounds: </span>
        <span className="m-0.5 ml-1 text-dark-number">{1}</span>
        <span className="m-0.5">/</span>
        <span className="m-0.5 text-dark-number">{MAX_ROUNDS}</span>
      </div>
      */}

      {lastCombatResult !== undefined && <CombatRoundOutcome lastCombatResult={lastCombatResult} />}

      <CombatActions onAttack={onAttack} />
    </section>
  );
}
