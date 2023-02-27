import { useMemo } from "react";
import BaseInfo from "./BaseInfo";
import PassTurnButton from "./PassTurnButton";
import ClaimTurnsButton from "./ClaimTurnsButton";
import { useActiveGuise } from "../../mud/hooks/useActiveGuise";
import { useCycleTurns } from "../../mud/hooks/useCycleTurns";
import { useWandererContext } from "../../contexts/WandererContext";
import { useLevel } from "../../mud/hooks/charstat";

export default function CycleInfo() {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const turns = useCycleTurns(cycleEntity);

  const levelData = useLevel(cycleEntity, guise?.levelMul);

  const isClaimTurnsAvailable = useMemo(() => {
    // TODO use proper availability
    return true;
  }, []);

  const turnsHtml = (
    <>
      <div className="flex ml-2">
        <div className="w-1/3 mr-5">
          <span className="text-dark-key">turns:</span>
          <span className="text-dark-number ml-1">{turns}</span>
        </div>
        {isClaimTurnsAvailable && (
          <div className="w-1/2 mr-0.5">
            <ClaimTurnsButton />
          </div>
        )}
      </div>
      <div className="flex w-full box-border w-48 m-1">
        <PassTurnButton />
      </div>
    </>
  );

  return (
    <div className="top-16 h-full">
      <BaseInfo
        entity={cycleEntity}
        name={guise?.name}
        locationName={null}
        levelData={levelData}
        turnsHtml={turnsHtml}
      />
    </div>
  );
}
