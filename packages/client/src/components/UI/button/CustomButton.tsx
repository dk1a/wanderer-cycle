import { ReactNode } from "react";
// import classes from "./customButton.module.scss";

type Props = {
  children: ReactNode;
  onClick: any;
};
const CustomButton = ({ children, onClick }: Props) => {
  return (
    <button
      onClick={onClick}
      className="group relative bg-curiousBlue-800 inline-block overflow-hidden border border-blue-600 px-4 py-1 focus:outline-none focus:ring"
    >
      <span className="absolute inset-y-0 left-0 w-[2px] bg-blue-800 transition-all group-hover:w-full group-active:bg-blue-600"></span>
      <span className="relative text-sm font-medium text-dark-200 transition-colors group-hover:text-white">
        {children}
      </span>
    </button>
  );
};

export default CustomButton;
