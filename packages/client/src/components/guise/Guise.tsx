import { Fragment } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import { useGuise } from "../../mud/hooks/useGuise";
import CustomButton from "../UI/button/CustomButton";
import GuiseSkill from "./GuiseSkill";
import TippyComment from "../tippyComment/TippyComment";
import "tippy.js/dist/tippy.css";
import classes from "./Guise.module.scss";
import Skill from "../skill/Skill";
import { useGuiseSkill } from "../../mud/hooks/useGuiseSkill";

interface GuiseProps {
  entity: EntityIndex;
  onSelectGuise?: (guiseEntity: EntityIndex) => void;
}

export default function Guise({ entity, onSelectGuise }: GuiseProps) {
  const guise = useGuise(entity);

  let content;
  if (guise) {
    const statNames = Object.keys(guise.gainMul) as (keyof typeof guise.gainMul)[];

    content = (
      <>
        <header className={classes.guise__header}>{guise.name}</header>
        <Tooltip
          arrow={true}
          animation="perspective"
          position="left"
          html={<TippyComment content="multiplier of gained stats" />}
        >
          <div className={classes.guise__comment}>{"//stat Multipliers"}</div>
        </Tooltip>

        <div className={classes.guise__stats}>
          {statNames.map((statName) => (
            <Fragment key={statName}>
              <div className={classes.guise__gainMul}>
                {statName}:<div className={classes.guise__gainMul__string}>{guise.gainMul[statName]}</div>
              </div>
            </Fragment>
          ))}
        </div>

        <div className={classes.guise__comment}>
          <div className="w-28">{"//level/skill"}</div>
        </div>
        <div>
          {guise.skillEntities.map((entity) => (
            <GuiseSkill key={entity} entity={entity} />
          ))}
        </div>

        {onSelectGuise !== undefined && (
          <div className={classes.guiseBtn}>
            <CustomButton onClick={() => onSelectGuise(entity)}>Mint</CustomButton>
          </div>
        )}
      </>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className={classes.guise__container}>{content}</div>;
}
