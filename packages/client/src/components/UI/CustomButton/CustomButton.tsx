import React from "react";
import classes from "./customButton.module.scss";

type ButtonProps = JSX.IntrinsicElements["button"];

// TODO use forwardRef (see MethodButton.tsx and ModifierName.tsx)
const CustomButton = React.forwardRef<HTMLButtonElement, any>(({ children, disabled, onClick, style }, ref) => (
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
