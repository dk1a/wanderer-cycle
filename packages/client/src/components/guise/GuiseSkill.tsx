import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";
import Skill from "../skill/Skill";
import "react-tippy/dist/tippy.css";
import classes from "./Guise.module.scss";

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
      <Tooltip
        offset={100}
        position="left"
        animation="perspective"
        trigger="click"
        interactive
        html={<Skill skill={skill} />}
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
