import { NavLink, Outlet, RouterProvider, createBrowserRouter } from "react-router-dom";
import { GameRoot } from "./GameRoot";
import { InventoryPage } from "./pages/InventoryPage";
import WandererSelect from "./pages/WandererSelect";
import { GlobalMaps } from "./pages/GlobalMaps";
import { SkillsPage } from "./pages/SkillsPage";
import { CyclePage } from "./pages/CyclePage";
import { RootBoundary } from "./errorBoundaries";
import CustomButton from "./components/UI/Button/CustomButton";
import { useWandererContext } from "./contexts/WandererContext";

// game routes will display e.g. WandererSelect or Combat, if normal pages aren't available
const gameRoutes = [
  // show maps by default
  {
    title: "Maps",
    path: "",
    element: <GlobalMaps />,
  },
  // other game pages
  {
    title: "Inventory",
    path: "inventory",
    element: <InventoryPage />,
  },
  {
    title: "Skills",
    path: "skills",
    element: <SkillsPage />,
  },
  {
    title: "Cycle",
    path: "cycle",
    element: <CyclePage />,
  },
];

const otherRoutes = [
  {
    title: "Wanderer Select",
    path: "wanderer-select",
    element: <WandererSelect />,
  },
];

const router = createBrowserRouter([
  {
    path: "/",
    element: <Layout />,
    errorElement: <RootBoundary />,
    children: [
      {
        element: <GameRoot />,
        children: gameRoutes,
      },

      ...otherRoutes,
    ],
  },
]);

export function AppRouter() {
  return (
    <div>
      <RouterProvider router={router} />
    </div>
  );
}

function Layout() {
  const { handleThemeSwitch } = useWandererContext();

  return (
    <div>
      <div className="flex flex-row flex-wrap items-center justify-around h-16 bg-dark-500 border border-dark-400">
        <div>
          <CustomButton onClick={handleThemeSwitch}>change the mode</CustomButton>
        </div>
        <nav className="flex flex-wrap items-center justify-around w-2/3">
          {[...gameRoutes, ...otherRoutes].map(({ title, path }) => (
            <NavLink
              key={path}
              className={({ isActive }) => `transition duration-700 text-lg ${isActive ? "" : "text-dark-300"}`}
              to={path}
            >
              {title}
            </NavLink>
          ))}
          <div className="flex gap-x-8 text-dark-300">
            <NavLink to={"https://github.com/dk1a/wanderer-cycle"} target={"_blank"}>
              github
            </NavLink>
            <NavLink to={"https://discord.gg/9pX3h53VnX"} target={"_blank"}>
              discord
            </NavLink>
          </div>
        </nav>
      </div>
      <Outlet />
    </div>
  );
}
