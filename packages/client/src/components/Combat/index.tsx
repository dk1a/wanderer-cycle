import { useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/useExecuteCycleCombatRound";
import { attackAction, MAX_ROUNDS } from "../../mud/utils/combat";
import CombatActions from "./CombatActions";

export default function Combat() {
  const { selectedWandererEntity } = useWandererContext();
  const executeCycleCombatRound = useExecuteCycleCombatRound();

  const onAttack = useCallback(() => {
    if (!selectedWandererEntity) {
      throw new Error("Must select wanderer entity");
    }
    executeCycleCombatRound(selectedWandererEntity, [attackAction]);
  }, [selectedWandererEntity, executeCycleCombatRound]);

  // TODO result tracking ("none", "victory", "defeat")
  const encounterResultName = "none";
  const withResult = false;

  // ========== RENDER ==========
  return (
    <section className="p-2 flex flex-col justify-center items-center">
      <div className="flex justify-center">
        <span className="text-dark-key text-xl">rounds: </span>
        <span className="m-0.5 ml-1 text-dark-number">{1 /* TODO track rounds */}</span>
        <span className="m-0.5">/</span>
        <span className="m-0.5 text-dark-number">{MAX_ROUNDS}</span>
      </div>
      {withResult && <div className="text-center text-dark-string">{encounterResultName}</div>}
      <CombatActions allowActions={!withResult} disabled={false} onAttack={onAttack} />
    </section>
  );
}
