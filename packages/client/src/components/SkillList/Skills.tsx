import { EntityIndex } from "@latticexyz/recs";
import Skill from "../Skill";
import { useSkill } from "../../mud/hooks/useSkill";
import CustomButton from "../UI/Button/CustomButton";
import { useMemo, useState, useCallback } from "react";
import { useWandererContext } from "../../contexts/WandererContext";

const Skills = ({ entity, learned }: { entity: EntityIndex; learned: boolean }) => {
  const skill = useSkill(entity);
  const { learnCycleSkill, learnedSkillEntities } = useWandererContext();
  const [visible, setVisible] = useState(true);

  const onLearnEnter = useCallback(() => {
    if (!skill) {
      throw new Error("No select");
    }
    learnCycleSkill(skill.entity);
  }, [learnCycleSkill, skill]);

  const levelProps = useMemo(() => {
    // TODO add total exp data
    const exp = 10;
    const level = 1;

    return {
      name: "level",
      props: { exp, level },
    };
  }, []);
  return (
    <div className="p-0 flex items-center justify-between mb-8 ">
      <Skill
        skill={skill}
        visible={visible}
        setVisible={setVisible}
        className={
          learned
            ? "bg-dark-500 border border-dark-400 p-2 w-[400px] opacity-30"
            : "bg-dark-500 border border-dark-400 p-2 w-[400px]"
        }
      />
      <div className="h-1/2">
        {!learned && (
          <CustomButton
            onClick={onLearnEnter}
            disabled={levelProps.props.level < skill.requiredLevel || (visible && true)}
          >
            learn
          </CustomButton>
        )}
      </div>
    </div>
  );
};

export default Skills;
