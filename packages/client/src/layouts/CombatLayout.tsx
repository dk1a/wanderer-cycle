import { Outlet } from "react-router-dom";
import { useWandererContext } from "../mud/WandererProvider";
import { useStashCustom } from "../mud/stash";
import { getCycleCombatRewardRequests } from "../mud/utils/combat";
import { EnemyInfo } from "../components/info/EnemyInfo";
import { CombatPage } from "../pages/game/CombatPage";
import { CombatResultPage } from "../pages/game/CombatResultPage";

export function CombatLayout() {
  const { cycleEntity, enemyEntity } = useWandererContext();

  const combatRewardRequests = useStashCustom((state) => {
    if (cycleEntity === undefined) return [];
    return getCycleCombatRewardRequests(state, cycleEntity);
  });

  if (
    combatRewardRequests.length > 0
    // TODO need getter for CombatResult or change structure combatRewardRequests
    // || (lastCombatResult && lastCombatResult.combatResult !== CombatResult.NONE)
  ) {
    return (
      <>
        <CombatPage />
        <CombatResultPage combatRewardRequests={combatRewardRequests} />
      </>
    );
  }

  if (enemyEntity !== undefined) {
    return (
      <>
        <CombatPage />
        <div className="w-64">
          <EnemyInfo entity={enemyEntity} />
        </div>
      </>
    );
  }

  return <Outlet />;
}
