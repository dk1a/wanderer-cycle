import { ActionType, CombatAction } from "../../mud/utils/combat";

export function CombatActionText({ action }: { action: CombatAction }) {
  const { actionType, actionEntity } = action;

  if (actionType === ActionType.ATTACK) {
    return <div className="text-dark-string text-lg mt-10">you attack</div>;
  } else if (actionType === ActionType.SKILL) {
    return <div>you use skill {actionEntity}</div>;
  } else {
    console.warn(`Unknown actionType ${actionType}`);
    return <></>;
  }
}
