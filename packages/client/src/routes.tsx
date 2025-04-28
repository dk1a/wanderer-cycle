import { ReactNode } from "react";

import { SyncPage } from "./mud/SyncPage";

import { CyclePage } from "./pages/game/CyclePage";
import { InventoryPage } from "./pages/game/InventoryPage";
import { GlobalMapsPage } from "./pages/game/GlobalMapsPage";
import { SkillPage } from "./pages/game/SkillPage";
import { WandererSelect } from "./pages/game/WandererSelect";

import { AffixPage } from "./pages/admin/AffixPage";

export type ExternalRoute = {
  label: string;
  path: string;
  element?: undefined;
};

export type InternalRoute = {
  label: string;
  path: string;
  element: ReactNode;
};

export const combatRoutes: InternalRoute[] = [
  {
    label: "maps",
    path: "/",
    element: <GlobalMapsPage />,
  },
];

export const cycleRoutes: InternalRoute[] = [
  {
    label: "inventory",
    path: "/inventory",
    element: <InventoryPage />,
  },
  {
    label: "skills",
    path: "/skills",
    element: <SkillPage />,
  },
  {
    label: "cycle",
    path: "/cycle",
    element: <CyclePage />,
  },
];

export const wandererRoutes: InternalRoute[] = [
  {
    label: "w-select",
    path: "/wanderer-select",
    element: <WandererSelect />,
  },
];

export const rootRoutes: InternalRoute[] = [
  {
    label: "sync",
    path: "/sync",
    element: <SyncPage />,
  },
];

export const externalRoutes: ExternalRoute[] = [
  {
    label: "github",
    path: "https://github.com/dk1a/wanderer-cycle",
  },
  {
    label: "discord",
    path: "https://discord.gg/9pX3h53VnX",
  },
];

export const adminRoutes: InternalRoute[] = [
  {
    label: "affixes",
    path: "/admin/affixes",
    element: <AffixPage />,
  },
];
