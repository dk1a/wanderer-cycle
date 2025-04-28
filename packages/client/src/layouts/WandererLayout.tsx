import { Outlet } from "react-router-dom";
import { useWandererContext, WandererProvider } from "../mud/WandererProvider";
import { WandererSelect } from "../pages/game/WandererSelect";

export function WandererLayout() {
  return (
    <WandererProvider>
      <WandererLayoutInner />
    </WandererProvider>
  );
}

function WandererLayoutInner() {
  const { selectedWandererEntity } = useWandererContext();
  if (selectedWandererEntity === undefined) {
    return <WandererSelect />;
  }

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

  return <Outlet />;
}
