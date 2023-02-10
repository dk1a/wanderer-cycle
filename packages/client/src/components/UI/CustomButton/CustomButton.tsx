import { ReactNode } from "react";
import classes from "./customButton.module.scss";

type Props = {
  children: ReactNode;
  onClick: any;
  style: any;
};
const CustomButton = ({ children, onClick, style }: Props) => {
  return (
    <button onClick={onClick} className={classes.customBtn} style={style}>
      {children}
    </button>
  );
};

export default CustomButton;
