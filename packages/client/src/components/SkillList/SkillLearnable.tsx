import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../../mud/hooks/skill";
import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import Skill from "../Skill";
import CustomButton from "../UI/Button/CustomButton";
import { useLevel } from "../../mud/hooks/charstat";
import { useActiveGuise } from "../../mud/hooks/guise";
import { ActionType, CombatAction } from "../../mud/utils/combat";
import { useExecuteCycleCombatRound } from "../../mud/hooks/combat";
import { useManaCurrent } from "../../mud/hooks/currents";
import { useDuration } from "../../mud/hooks/useDuration";
import { SkillType } from "../../mud/utils/skill";
import UseSkillButton from "../UseSkillButton";

export default function SkillLearnable({ entity }: { entity: EntityIndex }) {
  const { learnCycleSkill, learnedSkillEntities, cycleEntity, selectedWandererEntity } = useWandererContext();
  const skill = useSkill(entity);
  const manaCurrent = useManaCurrent(cycleEntity);
  const duration = useDuration(cycleEntity, skill.entity);

  const guise = useActiveGuise(cycleEntity);
  const level = useLevel(cycleEntity, guise?.levelMul)?.level;

  const executeCycleCombatRound = useExecuteCycleCombatRound();
  const onSkill = useCallback(async () => {
    if (!selectedWandererEntity) throw new Error("Must select wanderer entity");
    const skillEntityId = skill.entityId;
    const skillAction: CombatAction = {
      actionType: ActionType.SKILL,
      actionEntity: skillEntityId,
    };
    await executeCycleCombatRound(selectedWandererEntity, [skillAction]);
  }, [selectedWandererEntity, executeCycleCombatRound, skill]);

  const isLearned = useMemo(() => learnedSkillEntities.includes(entity), [learnedSkillEntities, entity]);

  const [visible, setVisible] = useState(!isLearned);

  const onHeaderClick = useCallback(() => {
    // only expand collapsed data
    if (!visible) {
      setVisible(true);
    }
  }, [visible]);

  return (
    <div className="p-0 flex items-center mb-8">
      <Skill
        skill={skill}
        className={`bg-dark-500 border border-dark-400 p-2 w-[400px] ${
          duration !== undefined && duration.timeValue < 0 && "opacity-30"
        }`}
        isCollapsed={!visible}
        onHeaderClick={onHeaderClick}
      />
      <div className="h-1/2 ml-10">
        {!isLearned && (
          <CustomButton
            onClick={() => learnCycleSkill(entity)}
            disabled={level !== undefined && level < skill.requiredLevel}
          >
            learn
          </CustomButton>
        )}
        <UseSkillButton onSkill={onSkill} isLearned={isLearned} skill={skill} />
      </div>
    </div>
  );
}
