import { EntityIndex } from "@latticexyz/recs";
import Skill from "../Skill";
import { useSkill } from "../../mud/hooks/useSkill";
import CustomButton from "../UI/Button/CustomButton";
import { useMemo } from "react";
import { useWandererContext } from "../../contexts/WandererContext";
import { useCallback } from "react";

const Skills = ({ entity, learned }: { entity: EntityIndex; learned: boolean }) => {
  const skill = useSkill(entity);
  const { learnCycleSkill } = useWandererContext();

  const onLearnEnter = useCallback(() => {
    if (!skill) {
      throw new Error("No select");
    }
    learnCycleSkill(skill.entity);
  }, [learnCycleSkill, skill]);

  const levelProps = useMemo(() => {
    // TODO add total exp data
    const exp = 10;
    const level = 5;

    return {
      name: "level",
      props: { exp, level },
    };
  }, []);
  return (
    <div className="p-0 flex items-center justify-between ">
      <Skill skill={skill} className={"bg-dark-500 border border-dark-400 p-2 mb-8 w-[500px]"} />
      <div className="h-1/2">
        {!learned && (
          <CustomButton onClick={onLearnEnter} disabled={levelProps.props.level < skill.requiredLevel && true}>
            learn
          </CustomButton>
        )}
      </div>
    </div>
  );
};

export default Skills;
