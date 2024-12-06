import React from "react";
import { Navigate } from "react-router-dom";
import { useWandererContext } from "./contexts/WandererContext";

interface PrivateRouteProps {
  children: JSX.Element;
}

const PrivateRoute: React.FC<PrivateRouteProps> = ({ children }) => {
  const { selectedWandererEntity } = useWandererContext();

  if (!selectedWandererEntity) {
    return <Navigate to="/" />;
  }

  return children;
};

export default PrivateRoute;
