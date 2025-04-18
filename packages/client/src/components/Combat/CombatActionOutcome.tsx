import { useMemo } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import {
  CombatAction,
  CombatActionLog,
  CombatActionType,
} from "../../mud/utils/combat";
import { getSkill } from "../../mud/utils/skill";

export function CombatActionOutcome({
  actorLabel,
  actionLog,
}: {
  actorLabel: string;
  actionLog: CombatActionLog;
}) {
  return (
    <div className="space-x-2 text-dark-200">
      <span className="text-dark-type">{actorLabel}</span>
      <CombatActionText
        action={actionLog.action}
        defenderLifeDiff={actionLog.defenderLifeDiff}
      />
    </div>
  );
}

function CombatActionText({
  action,
  defenderLifeDiff,
}: {
  action: CombatAction;
  defenderLifeDiff: number;
}) {
  if (action.actionType === CombatActionType.ATTACK) {
    return (
      <span>
        <span className="text-dark-method">attacks</span> for{" "}
        <span className="text-dark-number">{-defenderLifeDiff}</span> damage
      </span>
    );
  } else if (action.actionType === CombatActionType.SKILL) {
    return (
      <CombatSkillText
        entity={action.actionEntity}
        defenderLifeDiff={defenderLifeDiff}
      />
    );
  } else {
    console.error(
      `Unknown actionType ${action.actionType}; actionEntity ${action.actionEntity}`,
    );
    return (
      <span>
        does something undefined with actionType {action.actionType}{" "}
        <span className="text-xs">(see the logs and tell the devs!)</span>
      </span>
    );
  }
}

function CombatSkillText({
  entity,
  defenderLifeDiff,
}: {
  entity: Hex;
  defenderLifeDiff: number;
}) {
  const skill = useStashCustom((state) => {
    try {
      return getSkill(state, entity);
    } catch (e) {
      console.error(e);
    }
  });

  const skillWithDamage = useMemo(() => {
    if (skill === undefined) return defenderLifeDiff !== 0;

    return Object.values(skill.spellDamage).some((value) => value !== 0);
  }, [skill, defenderLifeDiff]);

  return (
    <span>
      uses{" "}
      <span className="text-dark-method">
        {skill ? skill.name : "unknown skill"}
      </span>
      {skillWithDamage && (
        <CombatDamageText defenderLifeDiff={defenderLifeDiff} />
      )}
    </span>
  );
}

function CombatDamageText({ defenderLifeDiff }: { defenderLifeDiff: number }) {
  return (
    <span>
      for <span className="text-dark-number">{defenderLifeDiff}</span> damage
    </span>
  );
}
