import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/guise";
import SkillLearnable from "./SkillLearnable";
import { useLearnedSkillEntities } from "../../mud/hooks/skill";
import { useMemo } from "react";

export default function SkillList() {
  const { cycleEntity, selectedWandererEntity, wandererMode } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const learnedSkills = useLearnedSkillEntities(selectedWandererEntity);

  const displaySkills = useMemo(() => {
    if (wandererMode) {
      return learnedSkills;
    } else {
      return guise?.skillEntities ?? [];
    }
  }, [wandererMode, learnedSkills, guise]);

  return (
    <div className="ml-36 w-full">
      <div className="text-2xl text-dark-comment m-2">{"// skills"}</div>
      <div className="flex flex-col">
        {displaySkills.map((entity) => (
          <div key={entity} className="w-full">
            <SkillLearnable entity={entity} withButtons={!wandererMode} />
          </div>
        ))}
      </div>
    </div>
  );
}
