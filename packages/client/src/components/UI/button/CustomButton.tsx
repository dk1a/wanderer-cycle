import { ReactNode } from "react";
import classes from "./customButton.module.scss";

type Props = {
  children: ReactNode;
  onClick: any;
};
const CustomButton = ({ children, onClick }: Props) => {
  return (
    <button onClick={onClick} className={classes.customBtn}>
      {children}
    </button>
  );
};

export default CustomButton;
