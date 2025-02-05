import { useWandererContext } from "../../contexts/WandererContext";
import { useActiveGuise } from "../../mud/hooks/guise";
import SkillLearnable from "./SkillLearnable";
import { useLearnedSkillEntities } from "../../mud/hooks/skill";
import { useMemo } from "react";

export default function SkillList() {
  const { cycleEntity, selectedWandererEntity, wandererMode } =
    useWandererContext();
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
    <section className={"flex  justify-center flex-col mx-5 md:mx-10"}>
      <div className="text-2xl text-dark-comment m-2">{"// skills"}</div>
      <div className="flex flex-col">
        {displaySkills.map((entity) => (
          <div key={entity} className="w-full">
            <SkillLearnable entity={entity} withButtons={!wandererMode} />
          </div>
        ))}
      </div>
    </section>
  );
}

// <div className={'w-full h-full'}>
//   <section className={'flex items-center justify-center'}>
//     <div className="flex justify-around">
//       <div className="flex flex-col w-1/2 ml-5 p-10">
//         <h3 className="mb-10 mt-10 text-2xl font-bold text-dark-comment">
//           {"// select a wanderer"}
//         </h3>
//         {displaySkills.map((entity) => (
//           <div key={entity} className="w-full">
//             <SkillLearnable entity={entity} withButtons={!wandererMode}/>
//           </div>
//         ))}
//       </div>
//     </div>
//   </section>
// </div>
