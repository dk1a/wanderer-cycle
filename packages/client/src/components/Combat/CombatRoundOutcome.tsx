import { OnCombatResultData } from "../../mud/hooks/combat";
import { CombatActionText } from "./CombatActionText";

export function CombatRoundOutcome({ lastCombatResult }: { lastCombatResult: OnCombatResultData }) {
  const { initiatorActions, enemyLifeDiff, cycleLifeDiff } = lastCombatResult;

  return (
    <>
      {initiatorActions.length > 0 && (
        <div>
          {initiatorActions.map((action, index) => (
            <CombatActionText key={`${action.actionEntity}_${index}`} action={action} />
          ))}
        </div>
      )}

      {enemyLifeDiff !== 0 && (
        <div>
          <span>enemy life</span>
          {": "}
          <span className="text-dark-number">{enemyLifeDiff}</span>
        </div>
      )}

      {cycleLifeDiff !== 0 && (
        <div>
          <span>your life</span>
          {": "}
          <span className="text-dark-number">{cycleLifeDiff}</span>
        </div>
      )}
    </>
  );
}
