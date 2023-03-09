import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../../mud/hooks/skill";
import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import Skill from "../Skill";
import CustomButton from "../UI/Button/CustomButton";
import { useLevel } from "../../mud/hooks/charstat";
import { useGuise } from "../../mud/hooks/guise";

export default function SkillLearnable({ entity }: { entity: EntityIndex }) {
  const { learnCycleSkill, learnedSkillEntities, cycleEntity } = useWandererContext();
  const skill = useSkill(entity);

  const isLearned = useMemo(() => learnedSkillEntities.includes(entity), [learnedSkillEntities, entity]);

  const [visible, setVisible] = useState(!isLearned);

  const onHeaderClick = useCallback(() => {
    // only expand collapsed data
    if (!visible) {
      setVisible(true);
    }
  }, [visible]);

  const guise = useGuise(cycleEntity);
  const level = useLevel(cycleEntity, guise?.levelMul)?.level;

  return (
    <div className="p-0 flex items-center mb-8">
      <Skill
        skill={skill}
        className={`bg-dark-500 border border-dark-400 p-2 w-[400px] ${isLearned ? "opacity-30" : ""}`}
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
      </div>
    </div>
  );
}
