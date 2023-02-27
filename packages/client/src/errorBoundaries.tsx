import { isRouteErrorResponse, useRouteError } from "react-router-dom";

// TODO more and better boundaries https://reactrouter.com/en/main/route/error-element
export function RootBoundary() {
  const error = useRouteError();

  if (isRouteErrorResponse(error)) {
    if (error.status === 404) {
      return <div>{"This page doesn't exist!"}</div>;
    }
  }

  return <div>Something went wrong</div>;
}
