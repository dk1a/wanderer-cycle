import { EntityIndex } from "@latticexyz/recs";
import { useSkill } from "../../mud/hooks/skill";
import Skill from "../Skill";
import Tippy from "@tippyjs/react";
import { left } from "@popperjs/core";

export default function GuiseSkill({ entity }: { entity: EntityIndex }) {
  const skill = useSkill(entity);
  let content;
  if (skill) {
    content = (
      <Tippy
        key={entity}
        delay={100}
        offset={[0, 20]}
        placement={left}
        arrow={true}
        trigger={"click"}
        interactive
        content={
          <div style={{ padding: 0 }}>
            <Skill skill={skill} className={"bg-dark-500 border border-dark-400 p-2 m-[-10px]"} />
          </div>
        }
      >
        <div className="w-full flex cursor-pointer justify-between">
          <div className="flex">
            <div className="text-dark-number text-lg cursor-pointer w-6 text-center mr-0.5">{skill.requiredLevel}.</div>
            <div className="text-dark-method text-lg cursor-pointer w-full">{skill.name}</div>
          </div>
        </div>
      </Tippy>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 flex">{content}</div>;
}
