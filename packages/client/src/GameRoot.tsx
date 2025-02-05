// import { Fragment } from "react";
import { Outlet } from "react-router-dom";
import { useWandererContext } from "./contexts/WandererContext";
import CycleInfo from "./components/info/CycleInfo";
// import CombatPage from "./pages/CombatPage";
// import CombatInfo from "./components/info/CombatInfo";
// import { CombatResultPage } from "./pages/CombatResultPage";
// import { CombatResult } from "./mud/hooks/combat";
// import { WandererInfo } from "./components/info/WandererInfo";
// import CombatPage from "./pages/CombatPage/CombatPage";
import WandererSelect from "./pages/WandererSelect/WandererSelect";
// import CombatResultPage from "./pages/CombatResultPage/CombatResultPage";

export function GameRoot() {
  const {
    selectedWandererEntity,
    // enemyEntity,
    // combatRewardRequests,
    // lastCombatResult,
    // cycleEntity,
    // wandererMode,
  } = useWandererContext();

  if (selectedWandererEntity === undefined) {
    return <WandererSelect />;
  }

  // if (enemyEntity !== undefined) {
  //   return (
  //     <div className="flex">
  //       <CycleInfo />
  //       <CombatPage />
  //       <div className="w-64">
  //         {/*<CombatInfo />*/}
  //       </div>
  //     </div>
  //   );
  // }

  // if (
  //   combatRewardRequests.length > 0 ||
  //   (lastCombatResult && lastCombatResult.combatResult !== CombatResult.NONE)
  // ) {
  //   return (
  //     <div className="flex">
  //       <CycleInfo />
  //       <CombatResultPage />
  //     </div>
  //   );
  // }
  //
  // if (wandererMode || cycleEntity === undefined) {
  //   return (
  //     <div className="flex">
  //       <WandererInfo />
  //       <Outlet />
  //     </div>
  //   );
  // }

  return (
    <div className="flex">
      <CycleInfo />
      <Outlet />
    </div>
  );
}
