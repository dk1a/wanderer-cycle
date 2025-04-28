import { Outlet } from "react-router-dom";
import { useWandererContext } from "../mud/WandererProvider";
import { EnemyInfo } from "../components/info/EnemyInfo";
import { CombatPage } from "../pages/game/CombatPage";

export function CombatLayout() {
  const { enemyEntity } = useWandererContext();

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
