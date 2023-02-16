import { levelToExp } from "../../../mud/utils/experience";

export interface StatLevelProgressProps {
  level: number | undefined;
  exp: number | null | undefined;
  buffedLevel?: number;
}

export default function StatLevelProgress({ level, buffedLevel, exp }: StatLevelProgressProps) {
  let nextProgress, nextReq, relProgress;
  if (level !== undefined && exp !== undefined && exp !== null) {
    nextProgress = exp - levelToExp(level);
    nextReq = levelToExp(level + 1) - levelToExp(level);
    relProgress = nextReq === 0 ? 100 : Math.round((nextProgress / nextReq) * 100);
  } else {
    relProgress = 0;
  }

  if (buffedLevel === undefined) {
    buffedLevel = level;
  }

  return (
    <div className="col-span-2 flex items-center box-border w-full ml-1">
      {exp !== null && (
        <div className="flex flex-col flex-grow pr-2 pl-2">
          <div className="justify-center text-xs">
            <span className="text-dark-200">{nextProgress}</span>
            <span className="text-dark-200">/</span>
            <span className="text-dark-200">{nextReq}</span>
          </div>
          <div className="flex h-1 bg-dark-400">
            <div className="bg-dark-300" style={{ width: `${relProgress}%` }}></div>
          </div>
        </div>
      )}
    </div>
  );
}
