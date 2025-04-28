import { Suspense } from "react";
import {
  Navigate,
  Route,
  BrowserRouter as Router,
  Routes,
} from "react-router-dom";
import { useSync } from "@latticexyz/store-sync/react";
import { useStashCustom } from "./mud/stash";
import { getSyncStatus } from "./mud/getSyncStatus";
import { WandererProvider } from "./mud/WandererProvider";
import { useWorldContract } from "./mud/useWorldContract";
import { SystemCallsProvider } from "./mud/SystemCallsProvider";
import { adminRoutes, AppRoute, gameRoutes } from "./routes";
import { Navbar } from "./components/ui/Navbar";
import { SyncPage } from "./mud/SyncPage";

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
      <WandererProvider>
        <AppRouter />
      </WandererProvider>
    </SystemCallsProvider>
  );
}

function AppRouter() {
  return (
    <Router>
      <div className="flex flex-col h-full">
        <Routes>
          <Route
            path="/admin/*"
            element={<Navbar routes={adminRoutes} />}
          ></Route>

          <Route path="/*" element={<Navbar routes={gameRoutes} />}></Route>
        </Routes>

        <div className="flex-1 overflow-y-auto ">
          <Routes>
            <Route path="/admin">{displayAppRoutes(adminRoutes)}</Route>

            {displayAppRoutes(gameRoutes)}

            <Route path="/*" element={<Navigate to="/" />} />
          </Routes>
        </div>
      </div>
    </Router>
  );
}

function displayAppRoutes(routes: AppRoute[]) {
  return routes.map(({ element, path }) => {
    return (
      <Route
        key={path}
        path={path}
        element={<Suspense fallback="Loading...">{element}</Suspense>}
      />
    );
  });
}
