import React from "react";
import { AppRoutes, routeConfig } from "../../pages/routeConfig/routeConfig";
import { AppLink } from "../utils/AppLink/AppLink";

interface NavbarProps {
  className?: string;
}

export const Navbar = ({ className }: NavbarProps) => {
  return (
    <div className={className}>
      <div>
        {Object.keys(routeConfig).map((routeKey) => {
          const route = routeConfig[routeKey as AppRoutes];

          if (route.external) {
            return (
              <a
                className={"mx-2"}
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
              <AppLink className={"mx-2"} key={routeKey} to={route.path}>
                <span>{routeKey.replace(/_/g, " ")}</span>
              </AppLink>
            );
          }
        })}
      </div>
    </div>
  );
};
