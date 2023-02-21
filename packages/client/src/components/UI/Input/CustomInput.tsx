import { ChangeEventHandler } from "react";

type InputProps = {
  value?: string;
  placeholder: string;
  onChange: ChangeEventHandler<HTMLInputElement>;
};
// TODO forwardRef
const CustomInput = ({ onChange, value, placeholder }: InputProps) => {
  return (
    <input
      placeholder={placeholder}
      onChange={onChange}
      className="
  bg-dark-500 border border-dark-400 text-dark-200 text-sm h-8 w-36 focus:border-dark-string block w-56 mx-2 p-2
  dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:border-dark-comment"
    ></input>
  );
};

export default CustomInput;
