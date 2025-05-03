import { Outlet } from "react-router-dom";
import { useWandererContext } from "./contexts/WandererContext";
import CycleInfo from "./components/info/CycleInfo";
import CombatInfo from "./components/info/CombatInfo";
// import { WandererInfo } from "./components/info/WandererInfo";
import WandererSelect from "./pages/game/WandererSelect";
import CombatPage from "./pages/game/CombatPage";
import { useStashCustom } from "./mud/stash";
import { getCycleCombatRewardRequests } from "./mud/utils/combat";
import { CombatResultPage } from "./pages/game/CombatResultPage";

export function GameRoot() {
  const {
    selectedWandererEntity,
    enemyEntity,
    cycleEntity,
    // combatRewardRequests,
    // wandererMode,
  } = useWandererContext();

  const combatRewardRequests = useStashCustom((state) =>
    getCycleCombatRewardRequests(state, cycleEntity),
  );

  if (selectedWandererEntity === undefined) {
    return <WandererSelect />;
  }

  if (
    combatRewardRequests.length > 0
    // TODO need getter for CombatResult or change structure combatRewardRequests
    // || (lastCombatResult && lastCombatResult.combatResult !== CombatResult.NONE)
  ) {
    return (
      <div className="flex">
        <CycleInfo />
        <CombatResultPage combatRewardRequests={combatRewardRequests} />
      </div>
    );
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
