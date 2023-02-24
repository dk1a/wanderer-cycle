import { NavLink, Outlet, RouterProvider, createBrowserRouter, Navigate } from "react-router-dom";
import { GameRoot } from "./GameRoot";
import { InventoryPage } from "./pages/InventoryPage";
import About from "./pages/About";
import classes from "./App.module.scss";
import WandererSelect from "./pages/WandererSelect";
import { GlobalMaps } from "./pages/GlobalMaps";
import { SkillsPage } from "./pages/SkillsPage";

// game routes will display e.g. WandererSelect or Combat, if normal pages aren't available
const gameRoutes = [
  // show maps by default
  {
    title: "Home",
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
];

const otherRoutes = [
  {
    title: "Wanderer Select",
    path: "wanderer-select",
    element: <WandererSelect />,
  },
  {
    title: "About",
    path: "about",
    element: <About />,
  },
];

const router = createBrowserRouter([
  {
    path: "/",
    element: <Layout />,
    errorElement: <Navigate to="/" />,
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
    <div className={classes.nav}>
      <RouterProvider router={router} />
    </div>
  );
}

function Layout() {
  return (
    <div className={classes.content}>
      <div className={classes.nav__container}>
        <nav className={classes.nav__list}>
          {[...gameRoutes, ...otherRoutes].map(({ title, path }) => (
            <NavLink
              key={path}
              className={({ isActive }) => (isActive ? classes.navLinkClassActive : classes.navLinkClass)}
              to={path}
            >
              {title}
            </NavLink>
          ))}
        </nav>
      </div>
      <Outlet />
    </div>
  );
}
