import { Routes, Route } from "react-router-dom";
import { Home } from "./pages/Home";
import Inventory from "./pages/Inventory";
import NotFound from "./pages/NotFound";
import About from "./pages/About";
import Layout from "./Layout";
import classes from "./App.module.scss";
import WandererSelect from "./components/wanderer/WandererSelect";

const AppContent = () => {
  return (
    <nav className={classes.nav}>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route path="/?dev=true&worldAddress=0x5FbDB2315678afecb367f032d93F642f64180aa3" element={<Home />} />
          <Route path="inventory" element={<Inventory />} />
          <Route path="wanderer-select" element={<WandererSelect />} />
          <Route path="about" element={<About />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </nav>
  );
};

export default AppContent;
