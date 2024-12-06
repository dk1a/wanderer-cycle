import MapsPage from "../MapsPage/MapsPage";
import React from "react";
import InventoryPage from "../InventoryPage/InventoryPage";
import SkillPage from "../SkillPage/SkillPage";
import CyclePage from "../CyclePage/CyclePage";
import WandererSelect from "../WandererSelect/WandererSelect";

export enum AppRoutes {
  WANDERER_SELECT = "WANDERER_SELECT",
  MAPS = "MAPS",
  INVENTORY = "INVENTORY",
  SKILLS = "SKILLS",
  CYCLE = "CYCLE",
  ABOUT = "ABOUT",
  NOT_FOUND = "NOT_FOUND",
  DISCORD = "DISCORD",
  GITHUB = "GITHUB",
}

export const RoutePath: Record<AppRoutes, string> = {
  [AppRoutes.WANDERER_SELECT]: "/",
  [AppRoutes.MAPS]: "/maps",
  [AppRoutes.INVENTORY]: "/inventory",
  [AppRoutes.SKILLS]: "/skills",
  [AppRoutes.CYCLE]: "/cycle",
  [AppRoutes.ABOUT]: "/about",
  [AppRoutes.NOT_FOUND]: "*",
  [AppRoutes.DISCORD]: "https://discord.gg/9pX3h53VnX",
  [AppRoutes.GITHUB]: "https://github.com/dk1a/wanderer-cycle",
};

interface AppRouteProps {
  path: string;
  element: JSX.Element | null;
  isProtected?: boolean;
  external?: boolean;
}

export const routeConfig: Record<AppRoutes, AppRouteProps> = {
  [AppRoutes.MAPS]: {
    path: RoutePath[AppRoutes.MAPS],
    element: <MapsPage />,
    isProtected: true,
  },
  [AppRoutes.INVENTORY]: {
    path: RoutePath[AppRoutes.INVENTORY],
    element: <InventoryPage />,
    isProtected: true,
  },
  [AppRoutes.SKILLS]: {
    path: RoutePath[AppRoutes.SKILLS],
    element: <SkillPage />,
    isProtected: true,
  },
  [AppRoutes.CYCLE]: {
    path: RoutePath[AppRoutes.CYCLE],
    element: <CyclePage />,
    isProtected: true,
  },
  [AppRoutes.WANDERER_SELECT]: {
    path: RoutePath[AppRoutes.WANDERER_SELECT],
    element: <WandererSelect />,
    isProtected: false,
  },
  [AppRoutes.GITHUB]: {
    path: RoutePath.GITHUB,
    element: null,
    external: true,
  },
  [AppRoutes.DISCORD]: {
    path: RoutePath.DISCORD,
    element: null,
    external: true,
  },
};
