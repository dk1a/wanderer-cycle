import { useWandererContext } from "../../mud/WandererProvider";
import { useStashCustom } from "../../mud/stash";
import { getActiveGuise } from "../../mud/utils/guise";
import SkillLearnable from "./SkillLearnable";
import { useMemo } from "react";

export default function SkillList() {
  const { cycleEntity } = useWandererContext();
  const guise = useStashCustom((state) => getActiveGuise(state, cycleEntity));

  const displaySkills = useMemo(() => {
    return guise?.skillEntities ?? [];
  }, [guise]);

  return (
    <section className={"flex  justify-center flex-col mx-5 md:mx-10"}>
      <div className="text-2xl text-dark-comment m-2">{"// skills"}</div>
      <div className="flex flex-col">
        {displaySkills.map((entity) => (
          <div key={entity} className="w-full">
            <SkillLearnable
              entity={entity}
              withButtons={cycleEntity !== undefined}
            />
          </div>
        ))}
      </div>
    </section>
  );
}
