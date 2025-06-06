import { useMemo, useState } from "react";
import { Outlet } from "react-router-dom";
import { Hex } from "viem";
import { useWandererContext } from "../mud/WandererProvider";
import { useStashCustom } from "../mud/stash";
import {
  getCycleCombatRewardLog,
  getCycleCombatRewardRequests,
} from "../mud/utils/combat";
import { EnemyInfo } from "../components/info/EnemyInfo";
import { Combat } from "../components/combat/Combat";

export function CombatLayout() {
  const { cycleEntity, cycleCombatEntity } = useWandererContext();
  const [lastCombatEntity, setLastCombatEntity] = useState<Hex | undefined>(
    undefined,
  );

  const resolvedCombatEntity = useMemo(
    () => cycleCombatEntity ?? lastCombatEntity,
    [cycleCombatEntity, lastCombatEntity],
  );

  const combatRewardRequests = useStashCustom((state) => {
    if (cycleEntity === undefined) return [];
    return getCycleCombatRewardRequests(state, cycleEntity);
  });

  const combatRewardLog = useStashCustom((state) => {
    if (resolvedCombatEntity === undefined) return;
    return getCycleCombatRewardLog(state, resolvedCombatEntity);
  });

  if (resolvedCombatEntity !== undefined || combatRewardRequests.length > 0) {
    return (
      <>
        <Combat
          combatEntity={resolvedCombatEntity}
          combatRewardRequests={combatRewardRequests}
          combatRewardLog={combatRewardLog}
          onCombatAction={() => setLastCombatEntity(cycleCombatEntity)}
          onCombatClose={() => setLastCombatEntity(undefined)}
        />
        {resolvedCombatEntity !== undefined && (
          <div className="w-64">
            <EnemyInfo entity={resolvedCombatEntity} />
          </div>
        )}
      </>
    );
  }

  return <Outlet />;
}
