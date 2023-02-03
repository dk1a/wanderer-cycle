import {NavLink, Outlet} from "react-router-dom";
import Footer from "./Footer";
import CustomButton from "../utils/UI/button/CustomButton";
import {useState} from "react";
import Modal from "../utils/UI/modal/Modal";



const Layout = () => {
    const navLinkClass = `transition duration-700 text-dark-300`
    const navLinkClassActive = `transition duration-700 underline decoration-dark-keyword`
    const [modalActive, setModalActive] = useState(false);

    const activeHandler = () => {
        setModalActive(true)
    }


    return (
        <>
            <div className='flex flex-row flex-wrap items-center justify-around h-16 font-medium mb-8'>
                <div className=" flex flex-wrap items-center justify-around w-1/2">
                    <NavLink className={({isActive}) => isActive ? navLinkClassActive : navLinkClass} to="/">Home</NavLink>
                    <NavLink className={({isActive}) => isActive ? navLinkClassActive : navLinkClass} to="/inventory">Inventory</NavLink>
                    <NavLink className={({isActive}) => isActive ? navLinkClassActive : navLinkClass} to="/wanderer-select">Wanderer Select</NavLink>
                    <NavLink className={({isActive}) => isActive ? navLinkClassActive : navLinkClass} to="/about">About Us</NavLink>
                </div>
                <div>
                    <CustomButton onClick={activeHandler}>Link a wallet</CustomButton>
                </div>
                <Modal active={modalActive} setActive={setModalActive}>
                    <div className='p-1 w-3/4 cursor-pointer m-2 border
                    bg-cyan-800 ease-in hover:bg-cyan-600
                    text-gray-100 text-lg border border-cyan-700'>
                        link a wallet
                    </div>
                    <div className='p-1 w-3/4 cursor-pointer m-2 border
                    bg-cyan-800 ease-in hover:bg-cyan-600
                    text-gray-100 text-lg border border-cyan-700'>
                        link a wallet
                    </div>
                    <div className='p-1 w-3/4 cursor-pointer m-2 border
                    bg-cyan-800 ease-in hover:bg-cyan-600
                    text-gray-100 text-lg border border-cyan-700'>
                        link a wallet
                    </div>
                </Modal>
            </div>
            <Outlet/>
            <Footer/>
        </>
    );
};

export default Layout;