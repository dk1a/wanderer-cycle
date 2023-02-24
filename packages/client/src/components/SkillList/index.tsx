import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/useActiveGuise";
import Skills from "./Skills";

const SkillList = () => {
  const { cycleEntity, learnedSkillEntities } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);

  return (
    <div>
      <div className="text-2xl text-dark-comment">{"// skills"}</div>
      <div className="flex flex-col">
        {guise?.skillEntities.map((entity) => (
          <div key={entity} className="w-[500px]">
            <Skills entity={entity} learned={learnedSkillEntities.some((i) => i === entity)}></Skills>
          </div>
        ))}
      </div>
    </div>
  );
};

export default SkillList;
