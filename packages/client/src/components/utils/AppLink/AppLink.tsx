import { Link, LinkProps } from "react-router-dom";
import { FC } from "react";

interface AppLinkProps extends LinkProps {
  className?: string;
}

export const AppLink: FC<AppLinkProps> = (props) => {
  const { to, className, children, ...otherProps } = props;

  return (
    <Link to={to} className={className} {...otherProps}>
      {children}
    </Link>
  );
};
