import "tailwindcss/tailwind.css";
import "react-toastify/dist/ReactToastify.css";
import ReactDOM from "react-dom/client";
import { ToastContainer } from "react-toastify";
import { App } from "./App";
import { setup } from "./mud/setup";
import { MUDProvider } from "./mud/MUDContext";
import { ComponentBrowser } from "./ComponentBrowser";
import '../index.css'
import {BrowserRouter} from "react-router-dom";

const rootElement = document.getElementById("react-root");
if (!rootElement) throw new Error("React root not found");
const root = ReactDOM.createRoot(rootElement);

// TODO: figure out if we actually want this to be async or if we should render something else in the meantime
setup().then((result) => {
  root.render(
    <MUDProvider {...result}>
        <BrowserRouter>
            <App />
        </BrowserRouter>
      <ToastContainer position="bottom-right" draggable={false} theme="dark" />
      {import.meta.env.DEV ? <ComponentBrowser /> : null}
    </MUDProvider>
  );
});
