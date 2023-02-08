import { NavLink, Outlet } from "react-router-dom";
// import Footer from "./components/footer/Footer";
import CustomButton from "./components/UI/button/CustomButton";
import { useState } from "react";
import Modal from "./components/UI/modal/Modal";
import classes from "./App.module.scss";

const Layout = () => {
  const [modalActive, setModalActive] = useState(false);

  const activeHandler = () => {
    setModalActive(true);
  };

  return (
    <>
      <div className={classes.nav__container}>
        <div className={classes.nav__list}>
          <NavLink className={({ isActive }) => (isActive ? classes.navLinkClassActive : classes.navLinkClass)} to="/">
            Home
          </NavLink>
          <NavLink
            className={({ isActive }) => (isActive ? classes.navLinkClassActive : classes.navLinkClass)}
            to="/inventory"
          >
            Inventory
          </NavLink>
          <NavLink
            className={({ isActive }) => (isActive ? classes.navLinkClassActive : classes.navLinkClass)}
            to="/wanderer-select"
          >
            Wanderer Select
          </NavLink>
          <NavLink
            className={({ isActive }) => (isActive ? classes.navLinkClassActive : classes.navLinkClass)}
            to="/about"
          >
            About Us
          </NavLink>
        </div>
        <div>
          <CustomButton onClick={activeHandler}>Link a wallet</CustomButton>
        </div>
        <Modal active={modalActive} setActive={setModalActive}>
          <div className={classes.modal__item}>link a wallet</div>
          <div className={classes.modal__item}>link a wallet</div>
          <div className={classes.modal__item}>link a wallet</div>
        </Modal>
      </div>
      <Outlet />
      {/*<Footer/>*/}
    </>
  );
};

export default Layout;
