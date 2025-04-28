import { useCallback } from "react";
import { Hex } from "viem";
import { useStashCustom } from "../../mud/stash";
import { useSystemCalls } from "../../mud/SystemCallsProvider";
import { getGuises } from "../../mud/utils/guise";
import { Guise } from "../Guise/Guise";

export function WandererSpawn({ disabled }: { disabled: boolean }) {
  const systemCalls = useSystemCalls();
  const guises = useStashCustom((state) => getGuises(state));

  const spawnWanderer = useCallback(
    async (guiseEntity: Hex) => {
      await systemCalls.spawnWanderer(guiseEntity);
    },
    [systemCalls],
  );

  return (
    <div>
      {guises.map((guise) => (
        <Guise
          key={guise.entity}
          guise={guise}
          disabled={disabled}
          onSelectGuise={spawnWanderer}
        />
      ))}
    </div>
  );
}
