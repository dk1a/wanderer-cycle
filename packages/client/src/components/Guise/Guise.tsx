import { Fragment } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import { useGuise } from "../../mud/hooks/useGuise";
import CustomButton from "../UI/CustomButton/CustomButton";
import GuiseSkill from "./GuiseSkill";
import TippyComment from "../TippyComment/TippyComment";
import "tippy.js/dist/tippy.css";
import classes from "./Guise.module.scss";

interface GuiseProps {
  entity: EntityIndex;
  onSelectGuise?: (guiseEntity: EntityIndex) => void;
  disabled: boolean;
}

export default function Guise({ entity, onSelectGuise, disabled }: GuiseProps) {
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
          <div className="w-28">{"//level/Skill"}</div>
        </div>
        <div>
          {guise.skillEntities.map((entity) => (
            <GuiseSkill key={entity} entity={entity} />
          ))}
        </div>

        {onSelectGuise !== undefined && (
          <div className={classes.guiseBtn}>
            <CustomButton onClick={() => onSelectGuise(entity)} disabled={disabled}>
              Spawn
            </CustomButton>
          </div>
        )}
      </>
    );
  } else {
    content = <span className="text-dark-number">{entity}</span>;
  }

  return <div className={classes.guise__container}>{content}</div>;
}
