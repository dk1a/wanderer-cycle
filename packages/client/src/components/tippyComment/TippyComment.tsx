import { ReactElement } from "react";

type commentProps = {
  children: ReactElement;
  content: ReactElement | string;
};

export default function TippyComment({ content }: commentProps) {
  return <div className="bg-dark-500 border border-dark-400 p-2 text-dark-method">{content}</div>;
}
