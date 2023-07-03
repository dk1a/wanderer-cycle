import { useState, useEffect } from "react";

interface ProgressBarProps {
  total: number;
  start: number;
}

export default function ProgressBar({ total, start }: ProgressBarProps) {
  const [progress, setProgress] = useState(start);

  useEffect(() => {
    const intervalId = setInterval(() => {
      setProgress((prevProgress) => prevProgress + 1);
    }, 100);

    return () => clearInterval(intervalId);
  }, []);

  const percent = ((progress - start) / (total - start)) * 100;

  return (
    <div className="w-full h-1 bg-dark-400">
      <div className="h-full bg-dark-200" style={{ width: `${percent}%` }}></div>
    </div>
  );
}
