import { useMemo } from "react";
import { useStashCustom } from "../../mud/stash";
import { getCombatLog } from "../../mud/utils/combat";
import { useWandererContext } from "../../contexts/WandererContext";
import { CombatRoundOutcome } from "./CombatRoundOutcome";
import CombatActions from "./CombatActions";
import { getFromMap } from "../../mud/utils/getMap";

export function Combat() {
  // TODO abstract Combat from wanderer context, accept initiator/retaliator arguments instead
  // (consider the player being retaliator too, that should be feasible later)
  const { cycleEntity, enemyEntity } = useWandererContext();

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

  return (
    <section className="px-4 flex flex-col items-center w-full">
      <div className="pt-1 text-dark-200 text-xs">
        {lastRound ? lastRound.roundIndex + 1 : 0} /{" "}
        {combatLog?.roundsMax ?? ""}
      </div>

      <div className="flex justify-center w-full">
        <div className="text-2xl text-dark-type mr-2">
          {map ? map.lootData.name : "Map"}
        </div>
        <span className="text-xl text-dark-comment"></span>
      </div>
      {enemyEntity ? (
        lastRound ? (
          <CombatRoundOutcome roundLog={lastRound} />
        ) : (
          <div></div>
        )
      ) : (
        <div>No active combat</div>
      )}
      <CombatActions />
    </section>
  );
}
