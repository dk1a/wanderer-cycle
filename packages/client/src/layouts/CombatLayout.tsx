import { useMemo, useState } from "react";
import { Outlet } from "react-router-dom";
import { Hex } from "viem";
import { useWandererContext } from "../mud/WandererProvider";
import { useStashCustom } from "../mud/stash";
import { getCycleCombatRewardRequests } from "../mud/utils/combat";
import { EnemyInfo } from "../components/info/EnemyInfo";
import { Combat } from "../components/combat/Combat";

export function CombatLayout() {
  const { cycleEntity, cycleCombatEntity: combatEntity } = useWandererContext();
  const [lastCombatEntity, setLastCombatEntity] = useState<Hex | undefined>(
    undefined,
  );

  const resolvedCombatEntity = useMemo(
    () => combatEntity ?? lastCombatEntity,
    [combatEntity, lastCombatEntity],
  );

  const combatRewardRequests = useStashCustom((state) => {
    if (cycleEntity === undefined) return [];
    return getCycleCombatRewardRequests(state, cycleEntity);
  });

  if (resolvedCombatEntity !== undefined || combatRewardRequests.length > 0) {
    return (
      <>
        <Combat
          enemyEntity={resolvedCombatEntity}
          combatRewardRequests={combatRewardRequests}
          onCombatAction={() => setLastCombatEntity(combatEntity)}
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
