import React from "react";
import classes from "./customButton.module.scss";

type ButtonProps = JSX.IntrinsicElements["button"];

const CustomButton = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ children, disabled, onClick, style, className }, ref) => (
    <button
      ref={ref}
      disabled={disabled}
      className={(disabled ? classes.customBtn__disabled : classes.customBtn) + " " + (className ?? "")}
      onClick={onClick}
      style={style}
    >
      {children}
    </button>
  )
);
CustomButton.displayName = "CustomButton";

export default CustomButton;
