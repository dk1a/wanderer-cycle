import classes from './modal.module.css'
import {ReactNode} from "react";


type Props = {
  children: ReactNode,
  active: any,
  setActive: any

}
const Modal = ({active, setActive, children}: Props) => {

  const activeHandler = () => {
      setActive(false)
  }
  return (
    <div className={active ? classes.modal__active : classes.modal}
       onClick={activeHandler}>
      <div className={classes.modal__content} onClick={e => e.stopPropagation()}>
          {children}
      </div>
    </div>
  );
};

export default Modal;