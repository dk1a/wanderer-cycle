import { useState } from "react";
import CustomButton from "../Button/CustomButton";

export default function CopyAndCopied({ textData }: { textData: string }) {
  const [copied, setCopied] = useState(false);

  const truncateFromMiddle = (fullStr: string, strLen: number, middleStr = "...") => {
    if (fullStr.length <= strLen) return fullStr;
    const midLen = middleStr.length;
    const charsToShow = strLen - midLen;
    const frontChars = Math.ceil(charsToShow / 2);
    const backChars = Math.floor(charsToShow / 2);
    return fullStr.substr(0, frontChars) + middleStr + fullStr.substr(fullStr.length - backChars);
  };

  const copyToClipBoard = () => {
    setCopied(true);
    if (textData !== undefined) {
      navigator.clipboard.writeText(textData).then(
        () => {
          console.log("copied");
        },
        (err) => {
          console.error(err);
        }
      );
    }
    setTimeout(() => {
      setCopied(false);
    }, 2000);
  };

  return (
    <div className="flex w-full items-center justify-center">
      <div className="text-[14px] text-center text-dark-300">{truncateFromMiddle(textData, 13, "...")}</div>
      <div>
        <CustomButton onClick={copyToClipBoard} style={{ border: "none", fontSize: "12px" }}>
          {!copied ? "copy" : "copied"}
        </CustomButton>
      </div>
    </div>
  );
}
