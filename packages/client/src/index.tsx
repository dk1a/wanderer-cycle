import "tailwindcss/tailwind.css";
import "react-toastify/dist/ReactToastify.css";
import { createRoot } from "react-dom/client";
import { ToastContainer } from "react-toastify";
import { App } from "./App";
import { setup } from "./mud/setup";
import { MUDProvider } from "./mud/MUDContext";
import { ComponentBrowser } from "./ComponentBrowser";
import "../index.css";
import { WandererProvider } from "./contexts/WandererContext";
import { defaultToastOptions } from "./mud/utils/toast";

const rootElement = document.getElementById("react-root");
if (!rootElement) throw new Error("React root not found");
const root = createRoot(rootElement);

// TODO: figure out if we actually want this to be async or if we should render something else in the meantime
setup().then((result) => {
  root.render(
    <MUDProvider {...result}>
      <WandererProvider>
        <App />
        <ToastContainer {...defaultToastOptions} />
      </WandererProvider>
      {import.meta.env.DEV ? <ComponentBrowser /> : null}
    </MUDProvider>
  );
});
