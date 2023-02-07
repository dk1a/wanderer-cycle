import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import Skill from "../skill/Skill";
import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";

export default function GuiseSkill({ entity }: { entity: EntityIndex }) {
  const skill = useGuiseSkill(entity);

  // old tippy
  /*return (
    <Tippy duration={0} placement="bottom" content={<Skill id={skill.skillId} />}>
      <li className="flex hover:bg-dark-highlight">
        <div className="w-4 mr-2 text-center text-dark-number">{skill.level}</div>
        <div className="text-dark-method">{guise.skillData.name}</div>
      </li>
    </Tippy>
  );*/

  let content;
  if (skill) {
    content = (
      <>
        <div>
          <div className="text-dark-method text-lg cursor-pointer">{skill.requiredLevel}.</div>
        </div>
        <Tooltip trigger="click" interactive html={<Skill skill={skill} />}>
          <div className="text-dark-method text-lg cursor-pointer">{skill.name}</div>
        </Tooltip>
      </>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 flex">{content}</div>;
}
