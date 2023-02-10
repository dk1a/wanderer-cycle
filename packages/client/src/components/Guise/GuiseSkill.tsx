import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import Skill from "../Skill/Skill";
import "react-tippy/dist/tippy.css";
import classes from "./Guise.module.scss";
import { tippy } from "@tippyjs/react";
import "../TippyComment/tippyTheme.scss";

export default function GuiseSkill({ entity }: { entity: EntityIndex }) {
  const skill = useGuiseSkill(entity);

  // old tippy
  /*return (
    <Tippy duration={0} placement="bottom" content={<Skill id={Skill.skillId} />}>
      <li className="flex hover:bg-dark-highlight">
        <div className="w-4 mr-2 text-center text-dark-number">{Skill.level}</div>
        <div className="text-dark-method">{Guise.skillData.name}</div>
      </li>
    </Tippy>
  );*/

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
        <div className={classes.guiseSkill__container}>
          <div>
            <div className={classes.guiseSkill__level}>{skill.requiredLevel}.</div>
          </div>
          <div className={classes.guiseSkill__name}>{skill.name}</div>
        </div>
      </Tooltip>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className={classes.guiseSkill__parent}>{content}</div>;
}
