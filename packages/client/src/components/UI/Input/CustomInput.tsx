import { ChangeEventHandler } from "react";

type InputProps = {
  value: string;
  placeholder: string;
  onChange: ChangeEventHandler<HTMLInputElement>;
};
// TODO forwardRef
export default function CustomInput({ onChange, value, placeholder }: InputProps) {
  return (
    <input
      placeholder={placeholder}
      value={value}
      onChange={onChange}
      className="bg-dark-500 border border-dark-400 text-dark-300 text-sm h-10 w-36 block w-56 mx-2 p-2"
    ></input>
  );
}
