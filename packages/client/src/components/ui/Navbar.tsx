import { Link } from "react-router-dom";
import { ExternalRoute, InternalRoute } from "../../routes";

interface NavbarProps {
  routes: (ExternalRoute | InternalRoute)[];
}

export function Navbar({ routes }: NavbarProps) {
  return (
    <nav className="relative bg-dark-400 text-dark-300 flex items-center justify-center border-y border-dark-300 w-full">
      {routes.map((route) => {
        if (route.element === undefined) {
          return (
            <a
              className="min-w-6 px-2 py-1 -ml-px border-x border-dark-300 text-center"
              key={route.path}
              href={route.path}
              target="_blank"
              rel="noopener noreferrer"
            >
              <span>{route.label}</span>
            </a>
          );
        } else {
          return (
            <Link
              className="min-w-16 px-2 py-1 -ml-px border-x border-dark-300 text-center"
              key={route.path}
              to={route.path}
            >
              <span>{route.label}</span>
            </Link>
          );
        }
      })}

      {/* TODO mobile nav
      <div className="menu md:hidden">
        <input
          type="checkbox"
          id="burger-checkbox"
          className="burger-checkbox"
        />

        <label htmlFor="burger-checkbox" className="burger"></label>

        <ul className="menu-list">
          {routes.map((route) => {
            return (
              <li key={route.path}>
                {route.external ? (
                  <a
                    href={route.path}
                    target="_blank"
                    rel="noopener"
                    className="menu-item"
                  >
                    {route.label}
                  </a>
                ) : (
                  <Link to={route.path} className="menu-item">
                    {route.label}
                  </Link>
                )}
              </li>
            );
          })}
        </ul>
      </div>*/}
    </nav>
  );
}
