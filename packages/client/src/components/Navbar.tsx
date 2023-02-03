import { Routes, Route } from "react-router-dom";
import { Home } from "../pages/Home";
import Inventory from "../pages/Inventory";
import WandererSelect from "../pages/WandererSelect";
import NotFound from "../pages/NotFound";
import About from "../pages/About";
import Layout from "./Layout";
import WandererMint from "../pages/WandererMint";



const Navbar = () => {
    return (
        <nav className='w-screen h-12'>
            <Routes>
                <Route path='/' element={<Layout/>}>
                    <Route index element={<Home/>}/>
                    <Route path="inventory" element={<Inventory/>}/>
                    <Route path="wanderer-select" element={<WandererSelect/>}/>
                    <Route path="/mint" element={<WandererMint/>}/>
                    <Route path="about" element={<About/>}/>
                    <Route path="*" element={<NotFound/>} />
                </Route>
            </Routes>
        </nav>
    );
};

export default Navbar;