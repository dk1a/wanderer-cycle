import { Suspense } from "react";
import { Route, BrowserRouter as Router, Routes } from "react-router-dom";
import { Navbar } from "./components/Navbar/Navbar";
import { GameRoot } from "./GameRoot";
import { adminRoutes, AppRoute, gameRoutes } from "./routes";
import { useSyncStatus } from "./mud/useSyncStatus";

export const App = () => {
  const status = useSyncStatus();
  if (!status.isLive) {
    return (
      <div className="flex justify-center items-center h-screen">
        <span>
          <span className="text-dark-key">syncStatus</span>:{" "}
          <span className="text-dark-string">{status.message}</span> (
          {status.percentage.toFixed(1)}%)
        </span>
      </div>
    );
  }

  return (
    <div>
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

              <Route element={<GameRoot />}>
                {displayAppRoutes(gameRoutes)}
              </Route>

              <Route
                path="/*"
                element={
                  // TODO make a proper 404 page or redirect
                  <span className="text-dark-300">404 page not found</span>
                }
              />
            </Routes>
          </div>
        </div>
      </Router>
    </div>
  );
};

const displayAppRoutes = (routes: AppRoute[]) => {
  return routes.map(({ element, path }) => {
    return (
      <Route
        key={path}
        path={path}
        element={<Suspense fallback="Loading...">{element}</Suspense>}
      />
    );
  });
};
