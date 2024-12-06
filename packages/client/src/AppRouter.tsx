import React, { Suspense } from "react";
import { Route, Routes } from "react-router-dom";
import { routeConfig } from "./pages/routeConfig/routeConfig";
import PrivateRoute from "./PrivateRoute";

const AppRouter: React.FC = () => (
  <Routes>
    {Object.values(routeConfig).map(({ element, path, isProtected }) => {
      if (!element) return null;

      return (
        <Route
          key={path}
          path={path}
          element={
            <Suspense fallback={"Loading..."}>
              <div className="page-wrapper">
                {isProtected ? <PrivateRoute>{element}</PrivateRoute> : element}
              </div>
            </Suspense>
          }
        />
      );
    })}
  </Routes>
);

export default AppRouter;
