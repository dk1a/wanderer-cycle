import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/guise";
import SkillLearnable from "./SkillLearnable";

export default function SkillList() {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);

  return (
    <div className="ml-36 w-full">
      <div className="text-2xl text-dark-comment m-2">{"// skills"}</div>
      <div className="flex flex-col">
        {guise?.skillEntities.map((entity) => (
          <div key={entity} className="w-full">
            <SkillLearnable entity={entity} />
          </div>
        ))}
      </div>
    </div>
  );
}
