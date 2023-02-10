import { levelToExp } from "../../../mud/utils/experience";
import classes from "./statLevelProgress.module.scss";

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
    <div className={classes.stats__parent}>
      {exp !== null && (
        <div className={classes.stats__container}>
          <div className={classes.stats__number}>
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
