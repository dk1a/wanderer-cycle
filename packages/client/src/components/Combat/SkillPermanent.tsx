import { EntityIndex } from "@latticexyz/recs";
import Skill from "../Skill";
import { useSkill } from "../../mud/hooks/skill";
import CustomButton from "../UI/Button/CustomButton";
import { useCallback, useState } from "react";
import { useWandererContext } from "../../contexts/WandererContext";

export default function SkillPermanent({ entity }: { entity: EntityIndex }) {
  const skill = useSkill(entity);

  const { learnCycleSkill } = useWandererContext();
  const [visible, setVisible] = useState(true);

  const onHeaderClick = useCallback(() => {
    // only expand collapsed data
    setVisible(!visible);
  }, [visible]);

  return (
    <div className="p-0 flex items-start mb-8">
      <Skill
        skill={skill}
        className={`bg-dark-500 border border-dark-400 p-2 w-[400px]`}
        isCollapsed={!visible}
        onHeaderClick={onHeaderClick}
      />
      <div className="h-1/2 ml-10 mt-2">
        <CustomButton onClick={() => learnCycleSkill(entity)}>make permanent</CustomButton>
      </div>
    </div>
  );
}
