import {
  ButtonHTMLAttributes,
  FC,
  useCallback,
  useMemo,
  useState,
} from "react";

interface ButtonProps
  extends Omit<ButtonHTMLAttributes<HTMLButtonElement>, "onClick"> {
  onClick?: () => Promise<void> | void;
}

export const Button: FC<ButtonProps> = (props) => {
  const { className, children, disabled, onClick, ...otherProps } = props;

  const [isLoading, setIsLoading] = useState<boolean>(false);
  const onClickFinal = useCallback(async () => {
    if (!onClick) return;
    try {
      setIsLoading(true);
      await onClick();
    } finally {
      setIsLoading(false);
    }
  }, [onClick]);

  const disabledFinal = useMemo(() => {
    return disabled || isLoading;
  }, [disabled, isLoading]);

  return (
    <button
      type="button"
      disabled={disabledFinal}
      onClick={onClickFinal}
      className={
        " text-dark-control box-border text-center bg-dark-500 transition-all hover:bg-dark-400 active:bg-dark-600 " +
        " text-lg pr-2 pl-2 py-1 border border-dark-400 disabled:text-dark-comment disabled:cursor-not-allowed disabled:bg-dark-600 " +
        " leading-none " +
        className
      }
      {...otherProps}
    >
      {children}
    </button>
  );
};
