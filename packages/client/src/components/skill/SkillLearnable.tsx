import { useCallback, useMemo, useState } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { getSkill, SkillType } from "../../mud/utils/skill";
import { getLevel } from "../../mud/utils/charstat";
import { getActiveGuise } from "../../mud/utils/guise";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { useWandererContext } from "../../mud/WandererProvider";
import { Button } from "../ui/Button";
import { Skill } from "./Skill";
import { UseSkillButton } from "./UseSkillButton";

export function SkillLearnable({
  entity,
  withButtons,
}: {
  entity: Hex;
  withButtons: boolean;
}) {
  const systemCalls = useSystemCalls();
  const {
    learnCycleSkill,
    learnedSkillEntities,
    cycleEntity,
    cycleCombatEntity,
  } = useWandererContext();
  const skill = useStashCustom((state) => getSkill(state, entity));

  const guise = useStashCustom((state) => getActiveGuise(state, cycleEntity));
  const level = useStashCustom(
    (state) => getLevel(state, cycleEntity, guise?.levelMul)?.level,
  );

  const onSkill = useCallback(async () => {
    if (!cycleEntity) throw new Error("Cycle must be active");
    await systemCalls.cycle.castNoncombatSkill(cycleEntity, skill.entity);
  }, [cycleEntity, skill, systemCalls]);

  const isLearned = useMemo(
    () => learnedSkillEntities.includes(entity),
    [learnedSkillEntities, entity],
  );

  const [visible, setVisible] = useState(!isLearned);

  return (
    <div className="flex mb-8 items-center">
      <Skill
        skill={skill}
        className={`bg-dark-500 border border-dark-400 p-2 w-[400px]`}
        isCollapsed={!visible}
        onHeaderClick={() => setVisible((value) => !value)}
      />
      {withButtons && (
        <div className="h-1/2 ml-10">
          {!isLearned && (
            <Button
              onClick={() => learnCycleSkill(entity)}
              disabled={level !== undefined && level < skill.requiredLevel}
            >
              learn
            </Button>
          )}
          {isLearned &&
            cycleEntity &&
            skill.skillType === SkillType.NONCOMBAT && (
              <UseSkillButton
                userEntity={cycleEntity}
                skillEntity={entity}
                onSkill={onSkill}
                disabled={cycleCombatEntity !== undefined}
              />
            )}
        </div>
      )}
    </div>
  );
}
