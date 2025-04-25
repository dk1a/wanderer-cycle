import { CombatActionOutcome } from "./CombatActionOutcome";
import { CombatRoundLog } from "../../mud/utils/combat";

export function CombatRoundOutcome({ roundLog }: { roundLog: CombatRoundLog }) {
  // TODO less generic actor labels
  return (
    <div className="w-full flex flex-col items-center justify-center">
      <div className="w-full">
        {roundLog.initiatorActions.map((actionLog) => (
          <CombatActionOutcome
            key={actionLog.actionIndex}
            actorLabel={"Wanderer"}
            actionLog={actionLog}
          />
        ))}

        {roundLog.retaliatorActions.map((actionLog) => (
          <CombatActionOutcome
            key={actionLog.actionIndex}
            actorLabel={"Enemy"}
            actionLog={actionLog}
            className={"text-red-800"}
          />
        ))}
      </div>
    </div>
  );
}
