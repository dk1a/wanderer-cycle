import { Routes, Route } from "react-router-dom";
import { Home } from "./Home";
import Inventory from "./pages/Inventory";
import NotFound from "./pages/NotFound";
import About from "./pages/About";
import Layout from "./Layout";
import classes from "./App.module.scss";
import WandererSelect from "./components/wanderer/index";

const AppContent = () => {
  return (
    <nav className={classes.nav}>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route path="/home" element={<Home />} />
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
