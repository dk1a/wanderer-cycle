import { Fragment } from "react";
import { Hex } from "viem";
import { PSTAT } from "contracts/enums";
import { GuiseData } from "../../mud/utils/guise";
import { pstatNames } from "../../mud/utils/experience";
import { GuiseSkill } from "./GuiseSkill";
import { Button } from "../utils/Button/Button";

interface GuiseProps {
  guise: GuiseData;
  onSelectGuise?: (guiseEntity: Hex) => void;
  disabled?: boolean;
}

export default function Guise({ guise, onSelectGuise, disabled }: GuiseProps) {
  const pstats = Object.values(PSTAT) as PSTAT[];

  return (
    <div className="border border-dark-400 w-72 h-auto p-4 flex flex-col bg-dark-500 transform delay-500">
      <header className="text-2xl text-dark-type text-center">
        {guise.name}
      </header>
      <div className="text-dark-comment flex justify-between">
        {"// stat multipliers"}
      </div>

      <div className="flex flex-col justify-start items-baseline">
        {pstats.map((pstat) => (
          <Fragment key={pstat}>
            <div className="text-dark-key flex p-1 m-1">
              {pstatNames[pstat]}:
              <span className="text-dark-number flex mx-2">
                {guise.levelMul[pstat]}
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
