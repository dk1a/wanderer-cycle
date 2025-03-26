import { AppRoute } from "../../routes";
import { AppLink } from "../utils/AppLink/AppLink";

interface NavbarProps {
  routes: AppRoute[];
  className?: string;
}

export const Navbar = ({ routes, className }: NavbarProps) => {
  return (
    <nav
      className={`relative bg-dark-400 border-dark-400 text-dark-300 md:p-6 p-4 flex items-center justify-start md:justify-center w-full ${className}`}
    >
      <div className="hidden md:flex md:items-center gap-2">
        {routes.map((route) => {
          if (route.external) {
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
              <AppLink key={route.path} to={route.path}>
                <span>{route.label}</span>
              </AppLink>
            );
          }
        })}
      </div>

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
                  <AppLink to={route.path} className="menu-item">
                    {route.label}
                  </AppLink>
                )}
              </li>
            );
          })}
        </ul>
      </div>
    </nav>
  );
};
