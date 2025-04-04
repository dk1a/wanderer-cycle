import { JSX } from "react";

import CyclePage from "./pages/game/CyclePage";
import InventoryPage from "./pages/game/InventoryPage";
import GlobalMapsPage from "./pages/game/GlobalMapsPage";
import SkillPage from "./pages/game/SkillPage";
import WandererSelect from "./pages/game/WandererSelect";

import AffixPage from "./pages/admin/AffixPage";

export interface AppRoute {
  label: string;
  path: string;
  element: JSX.Element | null;
  external?: boolean;
}

export const gameRoutes: AppRoute[] = [
  {
    label: "maps",
    path: "/maps",
    element: <GlobalMapsPage />,
  },
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
  {
    label: "wanderer-select",
    path: "/",
    element: <WandererSelect />,
  },
  {
    label: "github",
    path: "https://github.com/dk1a/wanderer-cycle",
    element: null,
    external: true,
  },
  {
    label: "discord",
    path: "https://discord.gg/9pX3h53VnX",
    element: null,
    external: true,
  },
];

export const adminRoutes: AppRoute[] = [
  {
    label: "affixes",
    path: "/admin/affixes",
    element: <AffixPage />,
  },
];
