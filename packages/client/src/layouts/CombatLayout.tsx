import { useMemo, useState } from "react";
import { Outlet } from "react-router-dom";
import { Hex } from "viem";
import { useWandererContext } from "../mud/WandererProvider";
import { useStashCustom } from "../mud/stash";
import { getCycleCombatRewardRequests } from "../mud/utils/combat";
import { EnemyInfo } from "../components/info/EnemyInfo";
import { Combat } from "../components/combat/Combat";

export function CombatLayout() {
  const { cycleEntity, enemyEntity } = useWandererContext();
  const [lastEnemyEntity, setLastEnemyEntity] = useState<Hex | undefined>(
    undefined,
  );

  const resolvedEnemyEntity = useMemo(
    () => enemyEntity ?? lastEnemyEntity,
    [enemyEntity, lastEnemyEntity],
  );

  const combatRewardRequests = useStashCustom((state) => {
    if (cycleEntity === undefined) return [];
    return getCycleCombatRewardRequests(state, cycleEntity);
  });

  if (resolvedEnemyEntity !== undefined || combatRewardRequests.length > 0) {
    return (
      <>
        <Combat
          enemyEntity={resolvedEnemyEntity}
          combatRewardRequests={combatRewardRequests}
          onCombatAction={() => setLastEnemyEntity(enemyEntity)}
          onCombatClose={() => setLastEnemyEntity(undefined)}
        />
        {resolvedEnemyEntity !== undefined && (
          <div className="w-64">
            <EnemyInfo entity={resolvedEnemyEntity} />
          </div>
        )}
      </>
    );
  }

  return <Outlet />;
}
