import { Fragment } from "react";
import { EntityIndex } from "@latticexyz/recs";
import { Tooltip } from "react-tippy";
import { useGuise } from "../../mud/hooks/useGuise";
import CustomButton from "../UI/CustomButton/CustomButton";
import GuiseSkill from "./GuiseSkill";
import TippyComment from "../TippyComment/TippyComment";
import "tippy.js/dist/tippy.css";

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
        <header className="text-2xl text-dark-type text-center">{guise.name}</header>
        <Tooltip
          arrow={true}
          animation="perspective"
          position="left"
          html={<TippyComment content="multiplier of gained stats" />}
        >
          <div className="text-dark-comment flex justify-between">{"//stat Multipliers"}</div>
        </Tooltip>

        <div className="flex flex-col justify-start items-baseline">
          {statNames.map((statName) => (
            <Fragment key={statName}>
              <div className="text-dark-key flex p-1 m-1">
                {statName}:<div className="text-dark-key flex p-1 m-1">{guise.gainMul[statName]}</div>
              </div>
            </Fragment>
          ))}
        </div>

        <div className="text-dark-comment flex justify-between">
          <div className="w-28">{"//level/Skill"}</div>
        </div>
        <div>
          {guise.skillEntities.map((entity) => (
            <GuiseSkill key={entity} entity={entity} />
          ))}
        </div>

        {onSelectGuise !== undefined && (
          <div className="flex justify-center my-2">
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

  return (
    <div
      className="border border-dark-400 w-72 h-auto p-4 flex flex-col
  bg-dark-500 transform delay-500"
    >
      {content}
    </div>
  );
}
