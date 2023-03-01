import { EntityIndex } from "@latticexyz/recs";
import Skill from "../Skill";
import { useSkill } from "../../mud/hooks/skill";
import CustomButton from "../UI/Button/CustomButton";
import { useCallback, useMemo, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";

const SkillLearnable = ({ entity }: { entity: EntityIndex }) => {
  const skill = useSkill(entity);
  const { learnCycleSkill, learnedSkillEntities } = useWandererContext();

  const isLearned = useMemo(() => learnedSkillEntities.includes(entity), [learnedSkillEntities, entity]);

  const [visible, setVisible] = useState(!isLearned);
  const onHeaderClick = useCallback(() => {
    // only expand collapsed data
    if (!visible) {
      setVisible(true);
    }
  }, [visible]);

  // TODO add real level data
  const level = 1;

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
          <CustomButton onClick={() => learnCycleSkill(entity)} disabled={level < skill.requiredLevel}>
            learn
          </CustomButton>
        )}
      </div>
    </div>
  );
};

export default SkillLearnable;
