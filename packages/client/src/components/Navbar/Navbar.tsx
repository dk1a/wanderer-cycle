import React from "react";
import { AppRoutes, routeConfig } from "../../pages/routeConfig/routeConfig";
import { AppLink } from "../utils/AppLink/AppLink";

interface NavbarProps {
  className?: string;
}

export const Navbar = ({ className }: NavbarProps) => {
  return (
    <nav className={`relative ${className}`}>
      <div className="hidden md:flex md:items-center gap-2">
        {Object.keys(routeConfig).map((routeKey) => {
          const route = routeConfig[routeKey as AppRoutes];

          if (route.external) {
            return (
              <a
                key={routeKey}
                href={route.path}
                target="_blank"
                rel="noopener noreferrer"
              >
                <span>{routeKey.replace(/_/g, " ")}</span>
              </a>
            );
          } else {
            return (
              <AppLink key={routeKey} to={route.path}>
                <span>{routeKey.replace(/_/g, " ")}</span>
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
          {Object.keys(routeConfig).map((routeKey) => {
            const route = routeConfig[routeKey as AppRoutes];
            return (
              <li key={routeKey}>
                {route.external ? (
                  <a
                    href={route.path}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="menu-item"
                  >
                    {routeKey.replace(/_/g, " ")}
                  </a>
                ) : (
                  <AppLink to={route.path} className="menu-item">
                    {routeKey.replace(/_/g, " ")}
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
