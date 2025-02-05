import { levelToExp } from "../../mud/utils/experience";

interface PStatsWithProgressProps {
  name: string;
  baseLevel: number | undefined;
  buffedLevel?: number;
  experience?: number;
}

export function PStatWithProgress({
  name,
  baseLevel,
  buffedLevel,
  experience,
}: PStatsWithProgressProps) {
  let nextProgress, nextReq, relProgress;
  if (baseLevel !== undefined && experience !== undefined) {
    nextProgress = experience - levelToExp(baseLevel);
    nextReq = levelToExp(baseLevel + 1) - levelToExp(baseLevel);
    relProgress =
      nextReq === 0 ? 100 : Math.round((nextProgress / nextReq) * 100);
  } else {
    relProgress = 0;
  }

  buffedLevel ??= baseLevel;

  return (
    <div className="p-2 flex">
      {/* TODO maybe improve styles, it's complicated but can easily overflow to next line with big numbers */}
      <span className="w-52">
        <span className="text-dark-key">{name}</span>:{" "}
        <span className="text-dark-number">{buffedLevel}</span>
        {baseLevel !== buffedLevel && (
          <span className="ml-1">
            (<span className="text-dark-number">{baseLevel}</span>)
          </span>
        )}
      </span>

      <div className="col-span-2 flex items-center box-border w-full ml-1">
        {experience !== undefined && (
          <div className="flex flex-col flex-grow pr-2 pl-2">
            <div className="justify-center text-xs">
              <span className="text-dark-200">{nextProgress}</span>
              <span className="text-dark-200 mx-0.5">/</span>
              <span className="text-dark-200">{nextReq}</span>
            </div>
            <div className="flex h-1 bg-dark-400">
              <div
                className="bg-dark-300"
                style={{ width: `${relProgress}%` }}
              ></div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
