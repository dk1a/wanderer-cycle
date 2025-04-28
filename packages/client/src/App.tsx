import {
  createBrowserRouter,
  Navigate,
  RouterProvider,
} from "react-router-dom";
import { useSync } from "@latticexyz/store-sync/react";
import { useStashCustom } from "./mud/stash";
import { getSyncStatus } from "./mud/getSyncStatus";
import { useWorldContract } from "./mud/useWorldContract";
import { SystemCallsProvider } from "./mud/SystemCallsProvider";
import {
  adminRoutes,
  combatRoutes,
  cycleRoutes,
  rootRoutes,
  wandererRoutes,
} from "./routes";
import { SyncPage } from "./mud/SyncPage";
import { WandererLayout } from "./layouts/WandererLayout";
import { CycleLayout } from "./layouts/CycleLayout";
import { CombatLayout } from "./layouts/CombatLayout";
import { RootLayout } from "./layouts/RootLayout";

const router = createBrowserRouter([
  {
    Component: RootLayout,
    children: [
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
      {
        path: "*",
        element: <Navigate to="/" />,
      },
    ],
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
      <RouterProvider router={router} />
    </SystemCallsProvider>
  );
}
