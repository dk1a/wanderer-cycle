// AppRouter.tsx
import React, { Suspense } from "react";
import { Route, Routes } from "react-router-dom";
import PrivateRoute from "./PrivateRoute";
import { GameRoot } from "./GameRoot";
import { routeConfig } from "./pages/routeConfig/routeConfig";

const AppRouter: React.FC = () => (
  <Routes>
    <Route path="/" element={<GameRoot />}>
      {Object.values(routeConfig)
        .filter((route) => !route.external)
        .map(({ element, path, isProtected }) => {
          if (!element) return null;

          return (
            <Route
              key={path}
              path={path.replace("/", "")}
              element={
                <Suspense fallback="Loading...">
                  {isProtected ? (
                    <PrivateRoute>{element}</PrivateRoute>
                  ) : (
                    element
                  )}
                </Suspense>
              }
            />
          );
        })}
    </Route>
  </Routes>
);

export default AppRouter;
