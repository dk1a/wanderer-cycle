import { ReactElement } from "react";
import classes from "./tippyComment.module.css";

type commentProps = {
  content: ReactElement | string;
};

export default function TippyComment({ content }: commentProps) {
  return <div className={classes.tippyComment}>{content}</div>;
}
