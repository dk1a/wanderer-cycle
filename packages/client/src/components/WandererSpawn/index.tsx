import { useCallback } from "react";
import { Hex } from "viem";
import { useMUD } from "../../MUDContext";
import Guise from "../Guise/Guise";
import { getGuises } from "../../mud/utils/guise";
import { useStashCustom } from "../../mud/stash";

export default function WandererSpawn({ disabled }: { disabled: boolean }) {
  const { systemCalls } = useMUD();
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
