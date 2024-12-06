import { ButtonHTMLAttributes, FC } from "react";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  className?: string;
  square?: boolean;
  disabled?: boolean;
}

export const Button: FC<ButtonProps> = (props) => {
  const { className, children, disabled, ...otherProps } = props;

  return (
    <button
      type="button"
      disabled={disabled}
      className={
        className +
        " text-dark-control box-border text-center bg-dark-500 transition-all hover:bg-dark-400 active:bg-dark-600\n" +
        "  text-lg pr-2 pl-2 py-1 border border-dark-400 disabled:text-dark-comment disabled:cursor-not-allowed disabled:bg-dark-600\n" +
        "  leading-none"
      }
      {...otherProps}
    >
      {children}
    </button>
  );
};
