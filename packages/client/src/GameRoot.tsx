import { Outlet } from "react-router-dom";
import { useWandererContext } from "./contexts/WandererContext";
import CycleInfo from "./components/info/CycleInfo";
import CombatInfo from "./components/info/CombatInfo";
// import { CombatResultPage } from "./pages/CombatResultPage";
// import { CombatResult } from "./mud/hooks/combat";
// import { WandererInfo } from "./components/info/WandererInfo";
import WandererSelect from "./pages/game/WandererSelect";
import CombatPage from "./pages/game/CombatPage";

export function GameRoot() {
  const {
    selectedWandererEntity,
    enemyEntity,
    // combatRewardRequests,
    // wandererMode,
  } = useWandererContext();

  if (selectedWandererEntity === undefined) {
    return <WandererSelect />;
  }

  return (
    <div className="relative w-full h-full">
      <div className="fixed top-[71px] left-0 w-64 h-[calc(100%-4rem)] z-10">
        <CycleInfo />
      </div>
      {enemyEntity !== undefined && (
        <div className="fixed top-[71px] right-0 w-64 h-[calc(100%-4rem)] z-10">
          <CombatInfo />
        </div>
      )}
      <div className="mx-auto max-w-[1424px] h-full px-4">
        <div className="ml-64 mr-64 min-h-[calc(100vh-4rem)]">
          {enemyEntity !== undefined ? <CombatPage /> : <Outlet />}
        </div>
      </div>
    </div>
  );

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

  // return (
  //   <div className="flex">
  //     <CycleInfo />
  //     <Outlet />
  //   </div>
  // );
}
