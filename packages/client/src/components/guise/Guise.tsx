import "tippy.js/dist/tippy.css";
import classes from "./Guise.module.scss";
import { Fragment } from "react";
import { useGuise } from "../../mud/hooks/useGuise";
import CustomButton from "../../utils/UI/button/CustomButton";
import "tippy.js/animations/perspective.css";
import GuiseSkill from "./GuiseSkill";
import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import TippyComment from "../tippyComment/TippyComment";

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
        <Tooltip animation="perspective" html={<TippyComment content="Multiplier of gained stats" />}>
          <div className={classes.guise__comment}>Stat Multipliers</div>
        </Tooltip>

        <div className="flex flex-col justify-start items-baseline">
          {statNames.map((statName) => (
            <Fragment key={statName}>
              <div className="text-dark-key flex p-1 m-1">
                {statName}:<div className="text-dark-number mx-2">{guise.gainMul[statName]}</div>
              </div>
            </Fragment>
          ))}
        </div>

        <div className={classes.guise__comment}>
          <div className="w-28">Level/Skill</div>
        </div>
        <div className="">
          {guise.skillEntities.map((entity) => (
            <GuiseSkill key={entity} entity={entity} />
          ))}
        </div>

        {onSelectGuise !== undefined && (
          <div className="flex justify-center mb-2">
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
