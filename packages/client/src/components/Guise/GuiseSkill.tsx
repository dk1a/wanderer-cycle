import { EntityIndex } from "@latticexyz/recs";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import Skill from "../Skill";
import "react-tippy/dist/tippy.css";
import Tippy from "@tippyjs/react";
import "../TippyComment/tippyTheme.scss";

export default function GuiseSkill({ entity }: { entity: EntityIndex }) {
  const skill = useGuiseSkill(entity);

  let content;
  if (skill) {
    content = (
      <Tippy
        key={entity}
        offset={[100, 20]}
        placement={"left"}
        arrow={true}
        animation={"perspective"}
        trigger={"click"}
        interactive
        content={
          <div style={{ padding: 0 }}>
            <Skill skill={skill} />
          </div>
        }
      >
        <div className="w-full flex">
          <div>
            <div className="text-dark-number text-lg cursor-pointer">{skill.requiredLevel}.</div>
          </div>
          <div className="text-dark-method text-lg cursor-pointer w-full">{skill.name}</div>
        </div>
      </Tippy>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 flex">{content}</div>;
}
