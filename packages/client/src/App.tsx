import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { useSync } from "@latticexyz/store-sync/react";
import { useStashCustom } from "./mud/stash";
import { getSyncStatus } from "./mud/getSyncStatus";
import { useWorldContract } from "./mud/useWorldContract";
import { SystemCallsProvider } from "./mud/SystemCallsProvider";
import {
  adminRoutes,
  combatRoutes,
  cycleRoutes,
  externalRoutes,
  rootRoutes,
  wandererRoutes,
} from "./routes";
import { Navbar } from "./components/ui/Navbar";
import { SyncPage } from "./mud/SyncPage";
import { WandererLayout } from "./layouts/WandererLayout";
import { CycleLayout } from "./layouts/CycleLayout";
import { CombatLayout } from "./layouts/CombatLayout";

const router = createBrowserRouter([
  ...rootRoutes,
  {
    Component: WandererLayout,
    children: [
      ...wandererRoutes,
      {
        Component: CycleLayout,
        children: [
          ...cycleRoutes,
          {
            Component: CombatLayout,
            children: combatRoutes,
          },
        ],
      },
    ],
  },
  {
    path: "/admin",
    children: adminRoutes,
  },
]);

const navbarRouter = createBrowserRouter([
  { path: "/admin", element: <Navbar routes={adminRoutes} /> },
  {
    path: "/",
    element: (
      <Navbar
        routes={[
          ...combatRoutes,
          ...cycleRoutes,
          ...wandererRoutes,
          ...rootRoutes,
          ...externalRoutes,
        ]}
      />
    ),
  },
]);

export function App() {
  const status = useStashCustom((state) => getSyncStatus(state));
  const sync = useSync();
  const worldContract = useWorldContract();
  //const { address: userAddress } = useAccount();

  if (!status.isLive || !sync.data /*|| !userAddress*/ || !worldContract) {
    return <SyncPage />;
  }

  return (
    <SystemCallsProvider syncResult={sync.data} worldContract={worldContract}>
      <div className="flex flex-col h-full">
        <RouterProvider router={navbarRouter} />

        <div className="flex-1 overflow-y-auto">
          <RouterProvider router={router} />
        </div>
      </div>
    </SystemCallsProvider>
  );
}
