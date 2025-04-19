import { useCallback, useMemo, useState } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { getSkill, SkillType } from "../../mud/utils/skill";
import { getLevel } from "../../mud/utils/charstat";
import { getActiveGuise } from "../../mud/utils/guise";
import { useMUD } from "../../MUDContext";
import { useWandererContext } from "../../contexts/WandererContext";
import { Button } from "../utils/Button/Button";
import Skill from "../Guise/Skill";
import { UseSkillButton } from "../UseSkillButton";

export default function SkillLearnable({
  entity,
  withButtons,
}: {
  entity: Hex;
  withButtons: boolean;
}) {
  const { systemCalls } = useMUD();
  const { learnCycleSkill, learnedSkillEntities, cycleEntity } =
    useWandererContext();
  const skill = useStashCustom((state) => getSkill(state, entity));

  const guise = useStashCustom((state) => getActiveGuise(state, cycleEntity));
  const level = useStashCustom(
    (state) => getLevel(state, cycleEntity, guise?.levelMul)?.level,
  );

  const onSkill = useCallback(async () => {
    if (!cycleEntity) throw new Error("Cycle must be active");
    await systemCalls.cycle.castNoncombatSkill(cycleEntity, skill.entity);
  }, [cycleEntity, skill]);

  const isLearned = useMemo(
    () => learnedSkillEntities.includes(entity),
    [learnedSkillEntities, entity],
  );

  const [visible, setVisible] = useState(!isLearned);

  const onHeaderClick = useCallback(() => {
    // only expand collapsed data
    if (!visible) {
      setVisible(true);
    }
  }, [visible]);

  return (
    <div className="p-0 flex mb-8 items-center">
      <Skill
        skill={skill}
        className={`bg-dark-500 border border-dark-400 p-2 w-[400px]`}
        isCollapsed={!visible}
        onHeaderClick={onHeaderClick}
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
          {isLearned && skill.skillType === SkillType.NONCOMBAT && (
            <UseSkillButton entity={entity} onSkill={onSkill} />
          )}
        </div>
      )}
    </div>
  );
}
