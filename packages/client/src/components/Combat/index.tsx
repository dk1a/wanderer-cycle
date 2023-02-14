import { useCallback, useMemo } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useExecuteCycleCombatRound } from "../../mud/hooks/useExecuteCycleCombatRound";
import { attackAction, MAX_ROUNDS } from "../../mud/utils/combat";
import EncounterActions from "./CombatActions";

export default function Encounter() {
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
    <section className="p-2">
      <div className="flex-default justify-center">
        <span className="text-dark-key">rounds: </span>
        <span className="number-item">{1 /* TODO track rounds */}</span>
        <span>/</span>
        <span className="number-item">{MAX_ROUNDS}</span>
      </div>
      {withResult && <div className="text-center text-dark-string">{encounterResultName}</div>}

      <EncounterActions allowActions={!withResult} disabled={false} onAttack={onAttack} />
    </section>
  );
}
