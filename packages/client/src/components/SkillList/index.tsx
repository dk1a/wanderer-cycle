import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/useActiveGuise";
import SkillLearnable from "./SkillLearnable";

const SkillList = () => {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);

  return (
    <div className="ml-36">
      <div className="text-2xl text-dark-comment">{"// skills"}</div>
      <div className="flex flex-col">
        {guise?.skillEntities.map((entity) => (
          <div key={entity} className="w-[500px]">
            <SkillLearnable entity={entity} />
          </div>
        ))}
      </div>
    </div>
  );
};

export default SkillList;
