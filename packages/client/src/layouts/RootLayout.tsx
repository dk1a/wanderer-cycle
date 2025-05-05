import { Outlet, useMatch } from "react-router-dom";
import {
  adminRoutes,
  combatRoutes,
  cycleRoutes,
  externalRoutes,
  rootRoutes,
  wandererRoutes,
} from "../routes";
import { Navbar } from "../components/ui/Navbar";

export function RootLayout() {
  const isAdmin = useMatch("/admin");

  return (
    <div className="flex flex-col h-full">
      <Navbar
        routes={
          isAdmin
            ? adminRoutes
            : [
                ...combatRoutes,
                ...cycleRoutes,
                ...wandererRoutes,
                ...rootRoutes,
                ...externalRoutes,
              ]
        }
      />
      <div className="flex-1 overflow-y-auto">
        <Outlet />
      </div>
    </div>
  );
}
