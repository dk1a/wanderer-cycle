import { useWandererContext } from "./contexts/WandererContext";
import WandererSelect from "./pages/WandererSelect";
import CycleInfo from "./components/info/CycleInfo";
import { Outlet } from "react-router-dom";
import CombatPage from "./pages/CombatPage";
import CombatInfo from "./components/info/CombatInfo";
import { CombatResultPage } from "./pages/CombatResultPage";
import { CombatResult } from "./mud/hooks/combat";
import { WandererInfo } from "./components/info/WandererInfo";

export function GameRoot() {
  const { selectedWandererEntity, enemyEntity, combatRewardRequests, lastCombatResult, cycleEntity, mode } =
    useWandererContext();

  if (selectedWandererEntity === undefined) {
    return <WandererSelect />;
  }

  if (enemyEntity !== undefined) {
    return (
      <div className="flex">
        <CycleInfo />
        <CombatPage />
        <div className="w-64">
          <CombatInfo />
        </div>
      </div>
    );
  }

  if (combatRewardRequests.length > 0 || (lastCombatResult && lastCombatResult.combatResult !== CombatResult.NONE)) {
    return (
      <div className="flex">
        <CycleInfo />
        <CombatResultPage />
      </div>
    );
  }

  if (mode) {
    return (
      <div className="flex">
        <WandererInfo />
        <Outlet />
      </div>
    );
  }

  if (cycleEntity === undefined) {
    return (
      <div className="flex">
        <WandererInfo />
        <Outlet />
      </div>
    );
  }

  return (
    <div className="flex">
      <CycleInfo />
      <Outlet />
    </div>
  );
}
