import { levelToExp } from "../../mud/utils/experience";

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
    <div className="col-span-2 flex items-center">
      <div className="text-lg w-8 h-7">
        <span className="number-item">{buffedLevel}</span>

        {level !== buffedLevel && (
          <span className="text-sm">
            (<span className="number-item">{level}</span>)
          </span>
        )}
      </div>
      {exp !== null && (
        <div className="flex flex-col flex-grow pr-2 pl-2">
          <div className="flex-default justify-center text-xs">
            <span className="number-item">{nextProgress}</span>
            <span>/</span>
            <span className="number-item">{nextReq}</span>
          </div>
          <div className="flex h-1 bg-dark-400">
            <div className="bg-dark-300" style={{ width: `${relProgress}%` }}></div>
          </div>
        </div>
      )}
    </div>
  );
}
