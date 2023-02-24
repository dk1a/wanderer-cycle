import { Routes, Route } from "react-router-dom";
import { Home } from "./Home";
import InventoryPage from "./pages/InventoryPage";
import NotFound from "./pages/NotFound";
import About from "./pages/About";
import Layout from "./Layout";
import classes from "./App.module.scss";
import WandererSelect from "./pages/WandererSelect";
import GlobalMaps from "./pages/GlobalMaps";
import CombatPage from "./pages/CombatPage";
import SkillPage from "./pages/SkillPage";

const AppContent = () => {
  return (
    <div className={classes.nav}>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route path="/home" element={<Home />} />
          <Route path="inventory" element={<InventoryPage />} />
          <Route path="wanderer-select" element={<WandererSelect />} />
          <Route path="global-maps" element={<GlobalMaps />} />
          <Route path="global-maps/:combat/:id" element={<CombatPage />} />
          <Route path="skills" element={<SkillPage />} />
          <Route path="about" element={<About />} />
          <Route path="*" element={<NotFound />} />
        </Route>
      </Routes>
    </div>
  );
};

export default AppContent;
