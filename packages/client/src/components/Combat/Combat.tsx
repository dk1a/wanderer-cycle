import { useMemo } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import {
  CombatResult,
  CycleCombatRewardRequest,
  getCombatLog,
} from "../../mud/utils/combat";
import { useWandererContext } from "../../mud/WandererProvider";
import { CombatRoundOutcome } from "./CombatRoundOutcome";
import { CombatActions } from "./CombatActions";
import { getFromMap } from "../../mud/utils/getMap";
import { CombatResultComponent } from "./CombatResultComponent";

interface CombatProps {
  enemyEntity: Hex | undefined;
  combatRewardRequests: CycleCombatRewardRequest[];
  onCombatAction: () => void;
  onCombatClose: () => void;
}

export function Combat({
  enemyEntity,
  combatRewardRequests,
  onCombatAction,
  onCombatClose,
}: CombatProps) {
  // TODO abstract Combat from wanderer context, accept initiator/retaliator arguments instead
  // (consider the player being retaliator too, that should be feasible later)
  const { cycleEntity } = useWandererContext();

  const map = useStashCustom((state) => {
    return getFromMap(state, enemyEntity);
  });

  const combatLog = useStashCustom((state) => {
    if (!cycleEntity || !enemyEntity) return undefined;
    return getCombatLog(state, cycleEntity, enemyEntity);
  });

  const lastRound = useMemo(() => {
    return combatLog && combatLog.rounds && combatLog.rounds.length > 0
      ? combatLog.rounds[combatLog.rounds.length - 1]
      : undefined;
  }, [combatLog]);

  const combatResult = useMemo(() => combatLog?.combatResult, [combatLog]);
  const isCombatFinished = useMemo(
    () => combatResult === undefined || combatResult !== CombatResult.NONE,
    [combatResult],
  );

  return (
    <section className="px-4 flex flex-col items-center w-full">
      <div className="pt-1 text-dark-200 text-xs">
        {lastRound ? lastRound.roundIndex + 1 : 0}
        {" / "}
        {combatLog?.roundsMax ?? ""}
      </div>

      <div className="flex justify-center w-full">
        <div className="text-2xl text-dark-type mr-2">
          {map ? map.name : "Map"}
        </div>
        <span className="text-xl text-dark-comment"></span>
      </div>
      <div className="min-h-20 mt-2">
        {enemyEntity && lastRound && (
          <CombatRoundOutcome roundLog={lastRound} />
        )}
      </div>
      {!isCombatFinished && enemyEntity && (
        <CombatActions onAfterActions={onCombatAction} />
      )}
      {isCombatFinished && (
        <CombatResultComponent
          combatResult={combatResult}
          mapEntity={map?.entity}
          combatRewardRequests={combatRewardRequests}
          onCombatClose={onCombatClose}
        />
      )}
    </section>
  );
}
