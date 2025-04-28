import { JSX } from "react";

import { SyncPage } from "./mud/SyncPage";

import { CyclePage } from "./pages/game/CyclePage";
import { InventoryPage } from "./pages/game/InventoryPage";
import { GlobalMapsPage } from "./pages/game/GlobalMapsPage";
import { SkillPage } from "./pages/game/SkillPage";
import { WandererSelect } from "./pages/game/WandererSelect";

import { AffixPage } from "./pages/admin/AffixPage";
import { GameRoot } from "./GameRoot";

export interface AppRoute {
  label: string;
  path: string;
  element: JSX.Element | null;
  external?: boolean;
}

export const gameRoutes: AppRoute[] = [
  {
    label: "maps",
    path: "/",
    element: (
      <GameRoot>
        <GlobalMapsPage />
      </GameRoot>
    ),
  },
  {
    label: "inventory",
    path: "/inventory",
    element: (
      <GameRoot>
        <InventoryPage />
      </GameRoot>
    ),
  },
  {
    label: "skills",
    path: "/skills",
    element: (
      <GameRoot>
        <SkillPage />
      </GameRoot>
    ),
  },
  {
    label: "cycle",
    path: "/cycle",
    element: (
      <GameRoot>
        <CyclePage />
      </GameRoot>
    ),
  },
  {
    label: "wanderer-select",
    path: "/wanderer-select",
    element: <WandererSelect />,
  },
  {
    label: "sync",
    path: "/sync",
    element: <SyncPage />,
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
