import { isRouteErrorResponse, NavLink, useRouteError } from "react-router-dom";
import CustomButton from "./components/UI/Button/CustomButton";

// TODO more and better boundaries https://reactrouter.com/en/main/route/error-element
export function RootBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    if (error.status === 404) {
      return (
        <div className="flex items-center justify-center mt-10">
          <div className="flex flex-col items-center">
            <span className="text-dark-string text-2xl">{"This page doesn't exist!"}</span>
            <span className="text-dark-control text-xl">go back to </span>
            <NavLink to={"/"}>
              <CustomButton>Home</CustomButton>
            </NavLink>
          </div>
        </div>
      );
    }
  }

  return <div>Something went wrong</div>;
}
