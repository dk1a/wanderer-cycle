import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import Skill from "../Skill";
import "react-tippy/dist/tippy.css";
import { tippy } from "@tippyjs/react";
import "../TippyComment/tippyTheme.scss";

export default function GuiseSkill({ entity }: { entity: EntityIndex }) {
  const skill = useGuiseSkill(entity);

  tippy("Tooltip", {
    theme: "my-theme",
  });

  let content;
  if (skill) {
    content = (
      <Tooltip
        key={entity}
        offset={100}
        position="left"
        distance={20}
        size={"regular"}
        arrow={true}
        arrowSize={"regular"}
        animation={"perspective"}
        trigger={"click"}
        interactive
        html={
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
      </Tooltip>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className="bg-dark-500 p-2 border border-dark-400 flex">{content}</div>;
}
