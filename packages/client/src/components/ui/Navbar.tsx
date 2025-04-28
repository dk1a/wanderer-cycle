import { Link } from "react-router-dom";
import { ExternalRoute, InternalRoute } from "../../routes";

interface NavbarProps {
  routes: (ExternalRoute | InternalRoute)[];
}

export function Navbar({ routes }: NavbarProps) {
  return (
    <nav className="relative bg-dark-400 border-dark-400 text-dark-300 p-2 flex items-center justify-center w-full">
      <div className="flex items-center gap-2">
        {routes.map((route) => {
          if (route.element === undefined) {
            return (
              <a
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
              <Link key={route.path} to={route.path}>
                <span>{route.label}</span>
              </Link>
            );
          }
        })}
      </div>

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
                    rel="noopener noreferrer"
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
