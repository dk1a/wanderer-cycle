import BaseInfo from "./BaseInfo";
import PassTurnButton from "./PassTurnButton";
import ClaimTurnsButton from "./ClaimTurnsButton";
import { useActiveGuise } from "../../mud/hooks/guise";
import { useCycleTurns, useGetClaimableTurns } from "../../mud/hooks/turns";
import { useWandererContext } from "../../contexts/WandererContext";
// import { useLevel } from "../../mud/hooks/charstat";
// import { useMemo } from "react";

export default function CycleInfo() {
  const { cycleEntity } = useWandererContext();
  const guise = useActiveGuise(cycleEntity);
  const turns = useCycleTurns(cycleEntity);

  // const guiseMul = useMemo(() => guise?.levelMul, [guise]);
  // const levelData = useLevel(cycleEntity, guiseMul);

  const claimableTurns = useGetClaimableTurns(cycleEntity);

  const turnsHtml = (
    <div className="flex ml-2">
      <div className="w-1/3 mr-5 flex">
        <span className="text-dark-key">turns:</span>
        <span className="text-dark-number ml-1">{turns}</span>
        <div className="flex">
          <PassTurnButton />
          {claimableTurns !== undefined && claimableTurns > 0 && (
            <div className="w-1/2 mr-0.5">
              <ClaimTurnsButton claimableTurns={claimableTurns} />
            </div>
          )}
        </div>
      </div>
    </div>
  );

  return (
    <div className="top-16 h-full">
      <BaseInfo
        entity={cycleEntity}
        name={guise?.name}
        locationName={null}
        // levelData={levelData}
        turnsHtml={turnsHtml}
      />
    </div>
  );
}
