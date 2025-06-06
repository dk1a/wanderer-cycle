import { useMemo } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import {
  CombatResult,
  CycleCombatRewardLog,
  CycleCombatRewardRequest,
  getCombatLog,
} from "../../mud/utils/combat";
import { CombatRoundOutcome } from "./CombatRoundOutcome";
import { CombatActions } from "./CombatActions";
import { getFromMap } from "../../mud/utils/getMap";
import { CombatResultComponent } from "./CombatResultComponent";

interface CombatProps {
  combatEntity: Hex | undefined;
  combatRewardRequests: CycleCombatRewardRequest[];
  combatRewardLog: CycleCombatRewardLog | undefined;
  onCombatAction: () => void;
  onCombatClose: () => void;
}

export function Combat({
  combatEntity,
  combatRewardRequests,
  combatRewardLog,
  onCombatAction,
  onCombatClose,
}: CombatProps) {
  const combatLog = useStashCustom((state) => {
    if (!combatEntity) return undefined;
    return getCombatLog(state, combatEntity);
  });

  const map = useStashCustom((state) => {
    return getFromMap(state, combatLog?.retaliatorEntity);
  });

  const latestRound = useMemo(() => {
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
        {latestRound ? latestRound.roundIndex + 1 : 0}
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
        {combatEntity && latestRound && (
          <CombatRoundOutcome roundLog={latestRound} />
        )}
      </div>
      {!isCombatFinished && combatEntity && (
        <CombatActions onAfterActions={onCombatAction} />
      )}
      {isCombatFinished && (
        <CombatResultComponent
          combatResult={combatResult}
          mapEntity={map?.entity}
          combatRewardRequests={combatRewardRequests}
          combatRewardLog={combatRewardLog}
          onCombatClose={onCombatClose}
        />
      )}
    </section>
  );
}
