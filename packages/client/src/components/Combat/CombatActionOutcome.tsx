import { useStashCustom } from "../../mud/stash";
import { CombatActionLog, CombatActionType } from "../../mud/utils/combat";
import { getSkill } from "../../mud/utils/skill";
import { ElementalNumbers } from "../ui/ElementalNumbers";
import { Elemental } from "../../mud/utils/elemental";

export function CombatActionOutcome({
  actorLabel,
  actionLog,
}: {
  actorLabel: string;
  actionLog: CombatActionLog;
}) {
  return (
    <div className="text-dark-200">
      <span className="text-dark-type">{actorLabel} </span>
      <CombatActionText actionLog={actionLog} />
    </div>
  );
}

function CombatActionText({ actionLog }: { actionLog: CombatActionLog }) {
  const action = actionLog.action;

  if (action.actionType === CombatActionType.ATTACK) {
    return (
      <span>
        <span className="text-dark-method">attacks</span>
        <CombatDamageText damage={actionLog.attackDamage} />
      </span>
    );
  } else if (action.actionType === CombatActionType.SKILL) {
    return <CombatSkillText actionLog={actionLog} />;
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

function CombatSkillText({ actionLog }: { actionLog: CombatActionLog }) {
  const skill = useStashCustom((state) => {
    try {
      return getSkill(state, actionLog.action.actionEntity);
    } catch (e) {
      console.error(e);
    }
  });

  return (
    <span>
      uses{" "}
      <span className="text-dark-method">
        {skill ? skill.name : "unknown skill"}
      </span>
      {actionLog.withAttack && (
        <CombatDamageText
          damage={actionLog.attackDamage}
          damageTypeName="attack"
        />
      )}
      {actionLog.withAttack && actionLog.withSpell && <span> and </span>}
      {actionLog.withSpell && (
        <CombatDamageText
          damage={actionLog.spellDamage}
          damageTypeName="spell"
        />
      )}
    </span>
  );
}

function CombatDamageText({
  damage,
  damageTypeName,
}: {
  damage: Elemental;
  damageTypeName?: string;
}) {
  damageTypeName = damageTypeName ? " " + damageTypeName : "";
  return (
    <span>
      {" for "}
      <ElementalNumbers data={damage} />
      {`${damageTypeName} damage`}
    </span>
  );
}
