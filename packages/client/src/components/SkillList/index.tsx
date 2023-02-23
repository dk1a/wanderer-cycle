import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/useActiveGuise";
import Skills from "./Skills";

const SkillList = () => {
  const { cycleEntity, learnCycleSkill, learnedSkillEntities } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);

  return (
    <div>
      <div className="text-2xl text-dark-comment">{"// skills"}</div>
      <div className="flex flex-col">
        {"//learn skill"}
        {guise?.skillEntities.map((entity) => (
          <div key={entity} className="w-[600px]">
            <Skills entity={entity} learned={false}></Skills>
          </div>
        ))}
      </div>
      <div>
        {"//learned skill"}
        {learnedSkillEntities?.map((entity) => (
          <div key={entity} className="w-[600px]">
            <Skills entity={entity} learned={true}></Skills>
          </div>
        ))}
      </div>
    </div>
  );
};

export default SkillList;
