import React from "react";
import { forwardRef, ReactNode } from "react";
import classes from "./customButton.module.scss";

type Props = {
  children: ReactNode;
  onClick: React.MouseEventHandler<HTMLButtonElement>;
  style: any;
  disabled: boolean;
};

// TODO use forwardRef (see MethodButton.tsx and ModifierName.tsx)
const CustomButton = React.forwardRef<HTMLButtonElement, Props>(({ children, disabled, onClick, style }, ref) => (
  <button
    ref={ref}
    disabled={disabled}
    className={disabled ? classes.customBtn__disabled : classes.customBtn}
    onClick={onClick}
    style={style}
  >
    {children}
  </button>
));
CustomButton.displayName = "CustomButton";
export default CustomButton;
