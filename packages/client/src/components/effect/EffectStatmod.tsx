import { useMemo } from "react";
import { useStashCustom } from "../../mud/stash";
import { EffectStatmodData } from "../../mud/utils/getEffect";
import { getBaseStatmod } from "../../mud/utils/statmod";

export function EffectStatmod({ statmodEntity, value }: EffectStatmodData) {
  const baseStatmod = useStashCustom((state) =>
    getBaseStatmod(state, statmodEntity),
  );
  const nameParts = useMemo(
    () => baseStatmod.name.split("#"),
    [baseStatmod.name],
  );
  return (
    <div className="flex flex-wrap">
      {nameParts.map((namePart, index) => (
        <div key={namePart} className="">
          {index !== 0 && (
            <span className="text-dark-number text-sm">{value}</span>
          )}
          <span className="text-dark-string text-sm">{namePart}</span>
        </div>
      ))}
    </div>
  );
}
