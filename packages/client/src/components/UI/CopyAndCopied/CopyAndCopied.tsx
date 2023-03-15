import { useState } from "react";
import copyDark from "../../img/copy.png";
import copyLight from "../../img/copyLight.png";

export default function CopyAndCopied({ textData }: { textData: string | undefined }) {
  const [copied, setCopied] = useState(false);
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
    }, 100);
  };

  return (
    <div className="flex justify-center ml-4">
      {!copied ? (
        <img src={copyDark} alt="copy" onClick={copyToClipBoard} className="cursor-pointer w-4 h-4" />
      ) : (
        <img src={copyLight} alt="copy" onClick={copyToClipBoard} className="cursor-pointer w-4 h-4" />
      )}
    </div>
  );
}
