import { Fragment } from "react";
import { Entity } from "@latticexyz/recs";
import { GuiseData } from "../../mud/utils/guise";
import { GuiseSkill } from "./GuiseSkill";
import { Button } from "../utils/Button/Button";

interface GuiseProps {
  guise: GuiseData;
  onSelectGuise?: (guiseEntity: Entity) => void;
  disabled?: boolean;
}

export default function Guise({ guise, onSelectGuise, disabled }: GuiseProps) {
  const statNames = Object.keys(
    guise.levelMul,
  ) as (keyof typeof guise.levelMul)[];

  return (
    <div className="border border-dark-400 w-72 h-auto p-4 flex flex-col bg-dark-500 transform delay-500">
      <header className="text-2xl text-dark-type text-center">
        {guise.name}
      </header>
      <div className="text-dark-comment flex justify-between">
        {"// stat multipliers"}
      </div>

      <div className="flex flex-col justify-start items-baseline">
        {statNames.map((statName) => (
          <Fragment key={statName}>
            <div className="text-dark-key flex p-1 m-1">
              {statName}:
              <span className="text-dark-number flex mx-2">
                {guise.levelMul[statName]}
              </span>
            </div>
          </Fragment>
        ))}
      </div>

      <div className="text-dark-comment flex justify-between">
        <div className="w-28">{"// level / skill"}</div>
      </div>
      <div>
        {guise.skillEntities.map((entity) => (
          <GuiseSkill key={entity} entity={entity} />
        ))}
      </div>

      {onSelectGuise !== undefined && (
        <div className="flex justify-center my-2">
          <Button
            onClick={() => onSelectGuise(guise.entity)}
            disabled={disabled}
          >
            Spawn
          </Button>
        </div>
      )}
    </div>
  );
}
