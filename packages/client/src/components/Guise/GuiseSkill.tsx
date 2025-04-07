import { Tooltip } from "react-tooltip";
import { Hex } from "viem";
import Skill from "./Skill";
import { useStashCustom } from "../../mud/stash";
import { getSkill } from "../../mud/utils/skill";

interface GuiseSkillProps {
  className?: string;
  entity: Hex;
}

export const GuiseSkill = ({ className, entity }: GuiseSkillProps) => {
  const skill = useStashCustom((state) => getSkill(state, entity));
  const uniqueId = `skill-${entity}`;

  return (
    <div
      id={uniqueId}
      className={
        "skill-name bg-dark-500 p-2 border border-dark-400 flex " + className
      }
    >
      <div className={"w-full flex cursor-pointer justify-between"}>
        <div className={"flex"}>
          <div
            className={
              "text-dark-number text-lg cursor-pointer w-6 text-center mr-0.5"
            }
          >
            {skill.requiredLevel}.
          </div>
          <div className={"text-dark-method text-lg cursor-pointer w-full"}>
            {skill.name}
          </div>
        </div>
      </div>
      <Tooltip anchorSelect={`#${uniqueId}`} place={"right"} className={""}>
        <Skill skill={skill} />
      </Tooltip>
    </div>
  );
};
