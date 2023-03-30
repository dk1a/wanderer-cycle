import React from "react";
type InputProps = JSX.IntrinsicElements["input"];

const CustomInput = React.forwardRef<HTMLInputElement, InputProps>(
  ({ onChange, value, placeholder, className }, ref) => (
    <input
      ref={ref}
      value={value}
      placeholder={placeholder}
      onChange={onChange}
      className={
        `bg-dark-500 border border-dark-400
        text-dark-200 text-sm h-10 w-full focus:border-dark-string
        block w-56 mx-2 p-2 dark:bg-gray-700 dark:border-gray-600 
        dark:placeholder-gray-400 dark:text-white dark:focus:border-dark-comment` + className
      }
    ></input>
  )
);
CustomInput.displayName = "CustomInput";

export default CustomInput;
