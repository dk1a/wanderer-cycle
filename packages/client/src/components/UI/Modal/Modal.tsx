import { ReactNode } from "react";
import classes from "./modal.module.css";

type Props = {
  children: ReactNode;
  active: any;
  setActive: any;
};
export default function Modal({ active, setActive, children }: Props) {
  const activeHandler = () => {
    setActive(false);
  };
  return (
    <div className={active ? classes.modal__active : classes.modal} onClick={activeHandler}>
      <div className={classes.modal__content} onClick={(e) => e.stopPropagation()}>
        {children}
      </div>
    </div>
  );
}
