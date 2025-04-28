import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { GlobalProviders } from "./GlobalProviders";
import { App } from "./App";

import "../index.css";
import "./index.css";

createRoot(document.getElementById("react-root")!).render(
  <StrictMode>
    <GlobalProviders>
      <App />
    </GlobalProviders>
  </StrictMode>,
);
