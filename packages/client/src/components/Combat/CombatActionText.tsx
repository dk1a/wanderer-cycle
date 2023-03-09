import { useMemo } from "react";
import { useMUD } from "../../mud/MUDContext";
import { ActionType, CombatAction } from "../../mud/utils/combat";
import { getSkill } from "../../mud/utils/skill";

export function CombatActionText({ action }: { action: CombatAction }) {
  const { world, components } = useMUD();
  const { actionType, actionEntity } = action;

  const skillName = useMemo(() => {
    if (actionType !== ActionType.SKILL) return "";
    const skillEntity = world.entityToIndex.get(actionEntity);
    if (skillEntity === undefined) return "";

    return getSkill(world, components, skillEntity).name;
  }, [world, components, actionType, actionEntity]);

  if (actionType === ActionType.ATTACK) {
    return <div className="text-dark-string text-[19px] h-6">you attack</div>;
  } else if (actionType === ActionType.SKILL) {
    return <div className="h-6">you use skill {skillName}</div>;
  } else {
    console.warn(`Unknown actionType ${actionType}`);
    return <div className="h6"></div>;
  }
}
